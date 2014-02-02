Yamate
======

Realtime yamanote line web application for AppCon held by Ministery of Internal affairs 

## How to setup

1. Install rbenv
2. Install ruby 2.0.0
```
$ rbenv install 2.0.0-p195
```
3. sinatra_websocket_template (0.0.1)を入れる
```
$ gem install sinatra_websocket_template
```
4. 依存を解決する
```
$ gem install bundler
$ bundle
```

## How to up server

```
$ bundle exec foreman start
```
