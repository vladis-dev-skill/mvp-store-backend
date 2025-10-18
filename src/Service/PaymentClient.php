<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface;
use Psr\Log\LoggerInterface;

class PaymentClient
{
    private HttpClientInterface $httpClient;
    private LoggerInterface $logger;
    private string $paymentServiceUrl;

    public function __construct(
        HttpClientInterface $httpClient,
        LoggerInterface $logger,
        string $paymentServiceUrl = 'http://store_payment_nginx'
    ) {
        $this->httpClient = $httpClient;
        $this->logger = $logger;
        $this->paymentServiceUrl = $paymentServiceUrl;
    }

    /**
     * Health check for Payment Service
     *
     * Calls Payment Service through API Gateway (systeme.io pattern):
     * Backend -> Gateway: http://mvp-store-gateway/inner-api/payment/health
     * Gateway -> Payment: http://mvp-store-payment:8080/inner-api/payment/health
     */
    public function healthCheck(): bool
    {
        try {
            $response = $this->httpClient->request('GET', $this->paymentServiceUrl . '/inner-api/payment/health', [
                'timeout' => 5,
            ]);

            return $response->getStatusCode() === 200;
        } catch (\Exception $e) {
            $this->logger->warning('Payment service health check failed', [
                'error' => $e->getMessage(),
                'url' => $this->paymentServiceUrl . '/inner-api/payment/health'
            ]);

            return false;
        }
    }
}