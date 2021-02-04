---
title: Say Hello To OpenEthereum
date: 2021-02-04 04:30:29
tags:
---

The [OpenEthereum(Parity)](https://github.com/openethereum/openethereum) has an 'One-line Binary Installer ([get.parity.io](https://web.archive.org/web/get.parity.io))' before, but it has been removed. I provide a little bash script to keep it works :)

## How to ?

### Make sure you have curl/unzip/sudo

``` bash
$ apt update && apt install curl unzip sudo
```

### Run

``` bash
$ bash <(curl https://pub.ccc.xxx/openethereum.sh -L)
```

###  Or if you have some 'problem' to access Github

``` bash
$ bash <(curl https://pub.ccc.xxx/openethereum.sh -L) -m fastgit #or wyzh (wuyanzheshui)
```

### Remove

``` bash
$ bash <(curl https://pub.ccc.xxx/openethereum.sh -L) -u
```
