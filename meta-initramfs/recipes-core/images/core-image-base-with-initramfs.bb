require recipes-core/images/core-image-base.bb

inherit dracut-initramfs

# This image is meant to have an initramfs that can be (re)generated at runtime on the target itself
CORE_IMAGE_EXTRA_INSTALL += " \
                             dracut \
                            "

