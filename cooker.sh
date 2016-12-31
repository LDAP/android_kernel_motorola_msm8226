#!/bin/bash

#############################################################
#                    K E R N E L  C O O K E R               #
#                        author : zakee94                   #
#                             v2.0                          #
#############################################################
# This script is to be placed in the root of your kernel directory.
# By default supports Moto G 2014, however can be modified for ANY device.

# Initialise the variables with addresses to be used later -->
export CROSS_COMPILE=/home/lucas/toolchains/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
architect=arm
BOOT=arch/arm/boot
defconfig=titan_defconfig
archive_name=CM+Kernel-R5
my_zip=//home/lucas/kernel/out/titan/nightly
anykernel=/home/lucas/kernel/zippers/anykernel2/

# Stores current directory to be used later -->
clear
curr_dir="$(pwd)"

# The beginning -->
echo -e "|------------------------------------------------------------|"
echo -e "|                      KERNEL COOKER                         |"
echo -e "|------------------------------------------------------------|"
echo -e "\nWELCOME $USER, LETS BEGIN..."
echo -e "To begin enter [Y/y], any other character to exit."
read begin

if [[ "$begin" == "y" || "$begin" == "Y" ]]; then
  echo -e "\n------------------------------------------------------------"
  echo -e "\nChecking for previous builds..."

    if [ -a $BOOT/Image ] || [ -a $BOOT/zImage ] || [ -a $BOOT/zImage-dtb ]; then
    echo -e "\nPREVIOUS BUILD DETECTED !"
    echo -e "Do you want to clean it ?"
    echo -e "To clean enter [Y/y], any other character to remain dirty."
    read clean

      if [[ "$clean" == "y" || "$clean" == "Y" ]]; then
        rm $BOOT/zImage-dtb $BOOT/zImage $BOOT/Image
      fi

    else
      echo -e "\nPREVIOUS BUILD NOT DETECTED. :)"
    fi

  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake clean & make Mrproper ??"
  echo -e "To clean enter [Y/y], any other character to remain dirty."
  read proper

  if [[ "$proper" == "y" || "$proper" == "Y" ]]; then
    make clean && make mrproper
    echo -e "\nDONE !"
  fi

  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake menuconfig ??"
  echo -e "To make enter [Y/y], any other character to not make."
  read mn_config

  if [[ "$mn_config" == "y" || "$mn_config" == "Y" ]]; then
      make menuconfig
      echo -e "\nDONE !"
  fi

  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake defconfig ??"
  echo -e "To make enter [Y/y], any other character to not make."
  read config

  if [[ "$config" == "y" || "$config" == "Y" ]]; then
    if [ -a .config ]; then
      echo -e "\nPrevious .config detected, make sure to clean first"
      echo -e "and then try again !"
    else
      ARCH=$architect make $defconfig
      echo -e "\nDONE !"
    fi
  fi

  echo -e "\n------------------------------------------------------------"
  echo -e "\nSTART THE BUILD ??"
  echo -e "To start enter [Y/y], any other character to not start."
  read build

  if [[ "$build" == "y" || "$build" == "Y" ]]; then
    if [ -a $BOOT/Image ] || [ -a $BOOT/zImage ] || [ -a $BOOT/zImage-dtb ]; then
    echo -e "\nPrevious build detected  make sure to clean first"
    echo -e "and then try again !"
    else
      make -j8 ARCH=$architect
    fi
  fi

  echo -e "\n------------------------------------------------------------"
  echo -e "\nChecking for compiled Images..."
  if [ -a $BOOT/zImage-dtb ] || [ -a $BOOT/zImage ]; then
    echo -e "\nCOMPILED zImage & zImage-dtb DETECTED !"
    echo -e "\nWhat do you want to work with ??"
    echo -e "Enter 1 for zImage & 2 for zImage-dtb"
    read images
    if [[ "$images" == "1" ]]; then
      zimg=zImage
    else
      zimg=zImage-dtb
    fi

    echo -e "\n[ $zimg SELECTED ]"
    check=0

    while [ $check==0 ]
    do
    echo -e "\n------------------------------------------------------------"
    echo -e "\nSELECT PACKAGING METHOD :-"
    echo -e "[*] Enter 1 for Any-Kernel packaging"
    echo -e "[*] Enter 2 to exit"
    read kernel
    case $kernel in

      1) # Any-Kernel building starts from here -->
      echo -e "\n------------------------------------------------------------"
      echo -e "\nChecking for previous images in Any-Kernel directoy..."

      if [ -a $anykernel/zImage ] || [ -a $anykernel/zImage-dtb ]; then
        echo -e "\nPrevious images detected !"
        echo -e "\nIt is highly recommended that you clean it."
        echo -e "To clean enter [Y/y], any other character to remain dirty."
        read clean_any

          if [[ "$clean_any" == "y" || "$clean_any" == "Y" ]]; then
            rm $anykernel/zImage-dtb $anykernel/zImage
            echo -e "\nCLEANED !"
          else
            echo -e "\nAnyways, the script will continue..."
            echo -e "BUT IF YOU FACE ERRORS, IT'S YOUR OWN FAULT !"
          fi
      else
        echo -e "\nPrevious build not detected. :)"
      fi

      # Copies
      echo -e "\nCopying $zimg into Any-Kernel directory..."
      cp -i $BOOT/$zimg $anykernel

      # Checks and renames
      if [[ "$zimg" == "zImage-dtb" ]]; then
      echo -e "\nRenaming..."
      mv $anykernel/$zimg $anykernel/zImage
      fi

      # Creates the zip archive
      echo -e "\nCreating flashable zip archive..."
      cd $anykernel
      zip -r9 $archive_name . -x \*.zip
      echo -e "\nALL DONE !!!"
      echo -e "ZIP SUCCESSFULLY CREATED !"

      # Moves if needed
      echo -e "\n------------------------------------------------------------"
      echo -e "\nDo you want to move zip in your prefered directory ??"
      echo -e "To move enter [Y/y], any other character to not move."
      read move

      if [[ "$move" == "y" || "$move" == "Y" ]]; then
        echo -e "\nMoving..."
        mv $archive_name.zip $my_zip
        echo -e "\nSuccessfully moved !"
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      else
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      fi
      exit 0
      ;;

      2)
      echo -e "\nExiting script..."
      echo -e "\n------------------------------------------------------------"
      exit 0
      ;;

      *)
      echo -e "\nWrong input entered, try again. ;)"
      check=0
      ;;

    esac
  done
  else
    echo -e "\nNo trace of any Images. :("
    echo -e "\nThis can be because of 2 reasons :-"
    echo -e "  1. Either you have not build the kernel OR"
    echo -e "  2. Your build is unsuccessfull."
    echo -e "\nPlease try again ! Exiting script..."
    echo -e "\n------------------------------------------------------------"
    exit 0
  fi
else
  echo -e "\nExiting script..."
  echo -e "\n------------------------------------------------------------"
  exit 0
fi
