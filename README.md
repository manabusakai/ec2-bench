# ec2-bench

## About

Apache Bench で負荷テストを行うとき、実行マシンの性能や回線によっては期待通りの負荷を掛けられません。

ec2-bench は Amazon EC2 を利用し、コマンド 1 つで複数台のインスタンスを立ち上げ、決められたパラメータで自動的に ab コマンドを実行します。また ab コマンドの実行が終わったら自動的にシャットダウンするため無駄なコストも発生しません。

Management Console からインスタンスを立ち上げたり、ssh でログインしてセットアップする必要がないため、手軽に負荷テストが実施できます。

## How to use

実行する前に `aws configure` で Access Key ID と Secret Access Key を設定してください。その IAM ユーザーには EC2 インスタンスを操作する権限が必要です。

### Configuration

`ec2-bench.conf` で AMI ID、インスタンスタイプ、インスタンス数、リクエスト数、同時クライアント数を設定します。

    $ cat ec2-bench.conf
    image_id="ami-29dc9228"
    instance_type="t2.micro"
    instance_count="2"
    request_number="100"
    client_number="10"

上記の場合だと ami-29dc9228 の AMI で t2.micro インスタンスを 2 台立ち上げ、同時クライアント数 10 / リクエスト数 100 で ab コマンドを実行します。

高い負荷を掛けたい場合は、インスタンスタイプを変えるなど適宜調整してください。

## Usage

引数に URL を渡してください。

    $ bash ec2-bench.sh http://www.example.com/
    Instances: i-xxxxxxxx i-xxxxxxxx
    Cleanup command: aws ec2 terminate-instances --instance-ids i-xxxxxxxx i-xxxxxxxx

成功するとインスタンス ID と、そのインスタンスを Terminate するコマンドが表示されます。負荷テストが終わったら、不要になったインスタンスを Terminate してください。

## License

MIT License