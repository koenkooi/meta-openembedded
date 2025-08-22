# Dracut-initramf-distro.bbclass: a class for enabling dracut at a distro level

python __anonymous() {
    # Inject initramfs into extlinux config, but only if it hasn't been configured yet
    # We could be more impolite and overwrite it, but let's save that for a later date
    extlinuxvibes = d.getVar('UBOOT_EXTLINUX')
    if extlinuxvibes == "1":
        extlinuxinitrd = d.getVar('UBOOT_EXTLINUX_INITRD')
        if not extlinuxinitrd:
            d.setVar('UBOOT_EXTLINUX_INITRD','../initramfs-dracut.img')
            extlinuxbootfiles = d.getVar('UBOOT_EXTLINUX_BOOT_FILES')
            if extlinuxbootfiles:
                d.setVar('UBOOT_EXTLINUX_BOOT_FILES', extlinuxbootfiles + ' initramfs-dracut.img')
}

