# 基础镜像
FROM ubuntu:20.04
# 维护者信息
MAINTAINER zhoushengzheng <zhoushengzheng@gmail.com>

RUN sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g"  /etc/apt/sources.list


# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SIZE=1600x840 \
    PASSWD=docker \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG}

# 安装
RUN apt-get -y update && \
    # tools
    apt-get install -y wget curl net-tools locales bzip2 unzip iputils-ping \
    traceroute firefox firefox-locale-zh-hans ttf-wqy-microhei \
    gedit gdebi python  gnome-font-viewer thunar awesome xfce4-terminal xrdp dbus-x11

RUN apt-get -y update && \
   apt-get remove -y ibus indicator-keyboard && apt-get purge -y ibus && \
   apt install -y fcitx-table-wbpy fcitx-config-gtk gdebi \
   gawk curl  zsh \
    git unzip wget    python3-pip  lsof sudo python \
    autojump  nmap iproute2 net-tools  axel netcat ripgrep fzf  xcompmgr feh libappindicator3-1 software-properties-common \
    konsole rofi


RUN   locale-gen zh_CN.UTF-8 

RUN im-config -n fcitx

RUN   wget 'http://cdn2.ime.sogou.com/dl/index/1599192613/sogoupinyin_2.3.2.07_amd64-831.deb?st=1cXIZ9xRzyq4GPkctOsB3Q&e=1602396489&fn=sogoupinyin_2.3.2.07_amd64-831.deb' -O sougou.deb && \
    dpkg -i sougou.deb ||   apt-get install -fy  && rm -f sougou.deb
 
ADD ./soft/lant.deb  /root/
ADD ./soft/pxy.sh  /usr/bin/pxy
RUN gdebi -n /root/lant.deb && rm -f /root/lant.deb

RUN wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' &&\
	gdebi -n google-chrome-stable_current_amd64.deb && rm -f google-chrome-stable_current_amd64.deb


USER root
WORKDIR /root

RUN  wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.10.0.x86_64.tar.gz | tar xz --strip 1 -C / 

RUN apt-get -y clean && apt -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed  -i  's/sans 8/JetBrainsMono Nerd Font Mono/g' /usr/share/awesome/themes/default/theme.lua


ADD ./conf/rc.lua /root/.config/awesome/rc.lua 
ADD ./soft/jetfont.ttf   /usr/share/fonts/jetfont.ttf
RUN fc-cache -f -v


RUN mkdir -p /root/.vnc && \
    echo $PASSWD | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo "awesome" > ~/.xsession 


# 创建脚本文件
RUN echo "#!/bin/bash\n" > /root/startup.sh && \
    # 修改密码
    echo 'if [ $PASSWD ] ; then' >> /root/startup.sh && \
    echo '    echo $PASSWD | vncpasswd -f > /root/.vnc/passwd' >> /root/startup.sh && \
    echo 'fi' >> /root/startup.sh && \
    # VNC
    echo 'vncserver -kill :0' >> /root/startup.sh && \
    echo "rm -rfv /tmp/.X*-lock /tmp/.X11-unix" >> /root/startup.sh && \
    echo 'vncserver :0 -geometry $SIZE -SecurityTypes None' >> /root/startup.sh && \
    echo 'tail -f /root/.vnc/*:0.log' >> /root/startup.sh && \
    # 可执行脚本
    chmod +x /root/startup.sh


# 导出特定端口
EXPOSE  5900

# 启动脚本
CMD ["/root/startup.sh"]
