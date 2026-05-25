# 使用Flutter基础镜像
FROM cirrusci/flutter:stable AS build

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY pubspec.yaml pubspec.lock ./

# 获取依赖
RUN flutter pub get

# 复制源代码
COPY . .

# 构建Web应用
RUN flutter build web --release

# 使用Nginx作为生产服务器
FROM nginx:alpine

# 复制构建产物
COPY --from=build /app/build/web /usr/share/nginx/html

# 复制Nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
