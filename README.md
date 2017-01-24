# OpenSSL Alpine

基于 Alpine 系统的 Docker 镜像，使用 OpenSSL 工具生成三层（根证书、中间证书、终端证书）相关的 x.509 协议的自签名证书链。

x509 是一个用来管理数字证书的公钥构架 ( PKI: public key infrastructure )，包括数字证书、公钥加密和传输层安全（TLS）协议，用与 WEB 和 email 通讯的数据加密。

x.509 是一种非常通用的证书格式。所有的证书都符合 ITU-T x.509 国际标准，因此(理论上)为一种应用创建的证书可以用于任何其他符合 x.509 标准的应用。

## 基本信息

* 镜像地址：endial/openssl-alpine
* 依赖镜像：endial/base-alpine



## 使用说明

可以使用 Linux 系统的 make 工具，按照 Makefiles 描述，生成相关的 Docker 镜像及容器。

### 编译生成镜像

在 Dockerfile 所在目录，使用以下命令生成一个本地镜像:

```
make build
```

### 运行容器

本意本地镜像后，可以使用以下命令生成相关的证书:

```
make run
```

### 验证证书

使用如下命令，运行一个容器，并检测生成的响应证书信息:

```
make verify
```



## 证书信息定制

可以通过覆盖以下参数的默认值，来定制生成包含自己所需信息的证书:

| VARIABLE        | DESCRIPTION      | DEFAULT               |
| :-------------- | :--------------- | :-------------------- |
| COUNTY          | 证书主题 - 国家        | CN                    |
| STATE           | 证书主题 - 省、州       | GuangDong             |
| LOCATION        | 证书主题 - 城市及地址     | ShenZhen              |
| ORGANISATION    | 证书主题 - 组织名       | Tidying Lab.          |
| ROOT_CN         | 根证书通用名           | Root                  |
| ISSUER_CN       | 中间证书通用名          | Authentication Center |
| PUBLIC_CN       | 公钥通用名            | tidying.org           |
| ROOT_NAME       | 根证书文件名（不用包含扩展名）  | root                  |
| ISSUER_NAME     | 中间证书文件名（不用包含扩展名） | intermediate          |
| PUBLIC_NAME     | 公钥文件名（不用包含扩展名）   | public                |
| RSA_KEY_NUMBITS | 用于生成证书的 RSA 秘钥位数 | 4048                  |
| DAYS            | 证书有效天数           | 365                   |

例如:

在当前路径下的 cert 子目录中，生成相关证书：

```
docker run \
  -e COUNTY="CN" \
  -e STATE="GuangDong" \
  -e LOCATION="ShenZhen" \
  -e ORGANISATION="Tidying Lab." \
  -e ISSUER_CN="J R R Tolkien" \
  -e PUBLIC_CN="tidying.org" \
  -e ISSUER_NAME="tolkien" \
  -e PUBLIC_NAME="hobbit" \
  -v ./cert:/srv/cert \
  endial/openssl-alpine
```

显示生成的证书:

```
ls -la ./cert
```

显示公开证书的详细信息:

```
openssl x509 -in ./cert/hobbit.crt -text -noout
```
