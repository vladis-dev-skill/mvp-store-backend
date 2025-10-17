<?php

namespace App\Controller\Api;

use App\Service\PaymentClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api')]
class TestController extends AbstractController
{
    public function __construct(
        private readonly PaymentClient $paymentClient
    ) {}

    #[Route('/health', name: 'backend_health', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return $this->json([
            'status' => 'ok',
            'service' => 'backend-service',
            'timestamp' => (new \DateTime())->format('Y-m-d H:i:s')
        ]);
    }

    #[Route('/payment-service-health', name: 'payment_service_health_check', methods: ['GET'])]
    public function paymentServiceHealth(): JsonResponse
    {
        try {
            $isHealthy = $this->paymentClient->healthCheck();

            return $this->json([
                'payment_service_status' => $isHealthy ? 'healthy' : 'unhealthy',
                'backend_service' => 'ok',
                'communication' => $isHealthy ? 'working' : 'failed',
                'timestamp' => (new \DateTime())->format('Y-m-d H:i:s')
            ]);
        } catch (\Exception $e) {
            return $this->json([
                'payment_service_status' => 'error',
                'backend_service' => 'ok',
                'communication' => 'failed',
                'error' => $e->getMessage(),
                'timestamp' => (new \DateTime())->format('Y-m-d H:i:s')
            ], Response::HTTP_SERVICE_UNAVAILABLE);
        }
    }
}