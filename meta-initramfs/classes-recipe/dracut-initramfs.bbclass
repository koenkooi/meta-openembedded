# Dracut-initramfs.bbclass: a class for generating an initramfs using dracut-ng based on the contents of the main rootfs

inherit core-image

# For the initramfs generated at buildtime
DEPENDS += "dracut-native"

# We need 'strip'
do_image[depends] += "virtual/cross-binutils:do_populate_sysroot "

# TODO: Add a switch for this, not every image needs a way to rebuild its initramfs.
# Include dracut for (re)generating the initramfs at runtime
CORE_IMAGE_EXTRA_INSTALL += " \
                             dracut \
                            "
python __anonymous() {
    initramfstype = d.getVar('INITRAMFS_TYPE')
    if not initramfstype:
        bb.warn("No INITRAMFS_TYPE specified.")
}

dracut_initramfs () {
    set -x

    # Counterintuitively, we need to *dis*able pseudo to get correct file ownershop (root:root) in the initramfs, not "builduser:buildgroup"
    export PSEUDO_UNLOAD=1

    # This needs to use something like kernel-arch.bbclass, with a LUT to turn in into 'uname -m' output, e.g. armv7a -> armv7l
    export DRACUT_ARCH="${TARGET_ARCH}"

    #export DRACUT_VERBOSENESS=" -v --debug"
    export DRACUT_VERBOSENESS=""

    export DRACUT_TESTBIN="$(readlink ${IMAGE_ROOTFS}/bin/sh)"
    export DRACUT_INSTALL="${STAGING_LIBDIR_NATIVE}/dracut/dracut-install$DRACUT_VERBOSENESS"
    export DRACUT_INSTALL_PATH="${bindir}:${sbindir}"
    export DRACUT_KERNEL_VERSION="$(ls -1 ${IMAGE_ROOTFS}/lib/modules | tail -n1)"
    export SYSTEMCTL="$(which systemctl)"

    export DRACUT_TMP="${S}/dracut-tmp"
    mkdir -p "$DRACUT_TMP"

    # Dracut being present in the rootfs is option, but the dracut recipe for version 107 and beyond generates a config file, use that if present.
    if [ -e ${IMAGE_ROOTFS}${libdir}/dracut/dracut.conf.d/${DISTRO}.conf ] ; then
        export DRACUT_CONF="--conf ${IMAGE_ROOTFS}${libdir}/dracut/dracut.conf.d/${DISTRO}.conf"
    fi

    # Dracut calls 'strip' directly and image.bbclass does not know that the toolchain sysroot staged for that to work, disable it
    dracut \
	--sysroot "${IMAGE_ROOTFS}" \
	$DRACUT_CONF \
	--libdirs=${libdir} \
	--tmpdir $DRACUT_TMP \
	--kver $DRACUT_KERNEL_VERSION \
	--strip \
	$DRACUT_VERBOSENESS \
	--force \
	${IMAGE_ROOTFS}/boot/initramfs-dracut.img 
}

IMAGE_PREPROCESS_COMMAND += "dracut_initramfs;"
