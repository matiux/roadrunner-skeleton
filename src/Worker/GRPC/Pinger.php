<?php

declare(strict_types=1);

namespace Worker\GRPC;

use Spiral\RoadRunner\GRPC\ContextInterface;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Worker\GRPC\Generated\Pinger\PingerInterface;
use Worker\GRPC\Generated\Pinger\PingRequest;
use Worker\GRPC\Generated\Pinger\PingResponse;

class Pinger implements PingerInterface
{
    public function __construct(
        //private readonly HttpClientInterface $httpClient,
    ) {}

    public function ping(ContextInterface $ctx, PingRequest $in): PingResponse
    {
        //$statusCode = $this->httpClient->get($in->getUrl())->getStatusCode();

        return new PingResponse([
            'status_response' => 'Sono il responso di un server gRPC',
        ]);
    }
}
