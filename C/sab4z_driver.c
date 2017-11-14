/*
 * Copyright (C) Telecom ParisTech
 * Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
 * 
 * This file must be used under the terms of the CeCILL. This source
 * file is licensed as described in the file COPYING, which you should
 * have received as part of this distribution. The terms are also
 * available at:
 * http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <linux/proc_fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include "sab4z_driver.h"
#define DRIVER_NAME "SAB4Z"

struct resource *res;
unsigned long remap_size;
void __iomem *base_addr;
static dev_t dev;
static struct cdev c_dev;
static struct class *cl;

static int sab4z_open(struct inode *inode, struct file *file)
{
	return 0;
}

static int sab4z_close(struct inode *inode, struct file *file)
{
	return 0;
}

static ssize_t sab4z_read(struct file *fp, char *buf, size_t count, loff_t * f_pos)
{
	uint64_t data;
  int tmp = 42;
	rmb();
  if(*(char *)&tmp == 42)
  { // Little endian
    data = ioread32(base_addr + 4);
    data <<= 32;
    data |= ioread32(base_addr);
  }
  else
  { // Big endian
    data = ioread32(base_addr);
    data <<= 32;
    data |= ioread32(base_addr + 4);
  }
	if(copy_to_user(buf,&data,sizeof(uint64_t)))
	{
		return -EACCES;
	}
	return sizeof(uint64_t);
}

static ssize_t sab4z_write(struct file *fp, const char *buf, size_t count, loff_t * f_pos)
{
	uint32_t data;
	void __iomem *addr;
	if(copy_from_user(&data, buf, sizeof(uint32_t)))
	{
		return -EACCES;
	}
	wmb();
	addr = (void *)(base_addr + 4);
	iowrite32(data, addr);
	return sizeof(uint32_t);
}

static long sab4z_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	void __iomem *addr;
	access_struct acc;

	switch(cmd)
	{
		case SAB4Z_WRITE8:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			wmb();
			addr = (void *)(base_addr + acc.addr);
			iowrite8((uint8_t)(acc.data), addr);
			break;
		case SAB4Z_READ8:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			rmb();
			addr = (void *)(base_addr + acc.addr);
			acc.data = ioread8(addr);
			if (copy_to_user((access_struct *)arg, &acc, sizeof(access_struct)))
			{
				return -EACCES;
			}
			break;
		case SAB4Z_WRITE16:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			wmb();
			addr = (void *)(base_addr + acc.addr);
			iowrite16((uint16_t)(acc.data), addr);
			break;
		case SAB4Z_READ16:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			rmb();
			addr = (void *)(base_addr + acc.addr);
			acc.data = ioread16(addr);
			if (copy_to_user((access_struct *)arg, &acc, sizeof(access_struct)))
			{
				return -EACCES;
			}
			break;
		case SAB4Z_WRITE32:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			wmb();
			addr = (void *)(base_addr + acc.addr);
			iowrite32(acc.data, addr);
			break;
		case SAB4Z_READ32:
			if (copy_from_user(&acc, (access_struct *)arg, sizeof(access_struct)))
			{
				return -EACCES;
			}
			rmb();
			addr = (void *)(base_addr + acc.addr);
			acc.data = ioread32(addr);
			if (copy_to_user((access_struct *)arg, &acc, sizeof(access_struct)))
			{
				return -EACCES;
			}
			break;
		default:
			return -EINVAL;
	}
	return 0;
}

static const struct file_operations sab4z_operations = {
	.open = sab4z_open,
	.release = sab4z_close,
	.read = sab4z_read,
	.write = sab4z_write,
	.unlocked_ioctl = sab4z_ioctl
};

static int sab4z_remove(struct platform_device *pdev)
{
	device_destroy(cl, dev);
	class_destroy(cl);
	cdev_del(&c_dev);
	unregister_chrdev_region(dev,1);
	iounmap(base_addr);
	release_mem_region(res->start, remap_size);
	return 0;
}

/* This functions is called when the module is linked to the kernel The
 * difference with the classic init function is that we have acces to
 * information on the device defined in the device tree. This information is in
 * the platform_device structure */
static int sab4z_probe(struct platform_device *pdev)
{
	int ret = 0;
	struct device *dev_ret;

	/* We get the information about the memory ressources here */
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if(!res) {
		dev_err(&pdev->dev, "No memory ressource\n");
		return -ENODEV;
	}

  /* Here we try to allocate the physical address space of the device. */
	remap_size = res->end - res->start + 1;
	if(!request_mem_region(res->start, remap_size, pdev->name)) {
		dev_err(&pdev->dev, "cannot request IO\n");
		return -ENXIO;
	}

  /* We remap the allocated physical address space into a virtual address space
   * */
	base_addr = ioremap(res->start, remap_size);
	if (base_addr == NULL) {
		dev_err(&pdev->dev, "couldn't ioremap memory at 0x%08lx\n", (unsigned long)res->start);
		ret = -ENOMEM;
		goto err_release_region;
	}

	if((ret = alloc_chrdev_region(&dev, 0, 1, "sab4z")))
	{
		dev_err(&pdev->dev, "couldn't allocate major number\n");
		goto err_unmap;
	}

	cdev_init(&c_dev, &sab4z_operations);
	
	if((ret = cdev_add(&c_dev, dev, 1)) < 0)
	{
		dev_err(&pdev->dev, "couldn't add the cdev structure\n");
		goto err_unregister;
	}

	if(IS_ERR(cl = class_create(THIS_MODULE, "sab4z")))
	{
		dev_err(&pdev->dev, "couldn't create a class\n");
		goto err_delete_cdev;
	}

	if(IS_ERR(dev_ret = device_create(cl, NULL, dev, NULL, "sab4z")))
	{
		dev_err(&pdev->dev, "error in device create\n");
		goto err_class_destroy;
	}
	
	printk(KERN_INFO DRIVER_NAME " probed at VA 0x%08lx\n", (unsigned long) base_addr);
	
	return 0;

err_class_destroy:
	class_destroy(cl);
err_delete_cdev:
	cdev_del(&c_dev);
err_unregister:
	unregister_chrdev_region(dev,1);
err_unmap:
	iounmap(base_addr);
err_release_region:
	release_mem_region(res->start, remap_size);
	
	return ret;
}

/* This structure contains all the compatible strings of the devices the driver
 * can work with The last element of the list must be empty */
static const struct of_device_id sab4z_of_match[] = {
	{.compatible  = "tpt,sab4z"},
	{},
};

/* Format the structure of_device_id */
MODULE_DEVICE_TABLE(of, sab4z_of_match);

/* We assemble all the functions and structures previously defined in this
 * structure.  It will be passed to the macro that register the module to the
 * kernel */
static struct platform_driver sab4z_drv = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table = sab4z_of_match},
	.probe = sab4z_probe,
	.remove = sab4z_remove
};

/* This macro is used to register the module to the kernel. It creates the
 * __init and __exit functions and bind them with the module_init() and
 * module_exit() macros */
module_platform_driver(sab4z_drv);

/* Macro that defines informations about the kernel module*/
MODULE_AUTHOR("Adrien Canuel");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION(DRIVER_NAME ": example software driver for SAB4Z");
MODULE_ALIAS(DRIVER_NAME);
