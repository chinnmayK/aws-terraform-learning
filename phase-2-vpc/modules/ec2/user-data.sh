#!/bin/bash
dnf install -y nginx
systemctl start nginx
systemctl enable nginx
