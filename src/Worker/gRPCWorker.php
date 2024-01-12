<?php

declare(strict_types=1);

namespace Worker;

require_once realpath(dirname(__DIR__).'/../').'/vendor/autoload.php';

use Spiral\RoadRunner\GRPC\Invoker;
use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;
use Symfony\Component\HttpClient\NativeHttpClient;
use Worker\GRPC\Generated\Pinger\PingerInterface;
use Worker\GRPC\Pinger;

$server = new Server(new Invoker(), [
    'debug' => false, // optional (default: false)
]);

$server->registerService(PingerInterface::class, new Pinger());

$server->serve(Worker::create());
