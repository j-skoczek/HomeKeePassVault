<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'app_home')]
    public function index(): Response
    {
        return $this->json([
            'message' => 'Welcome to HomeKeePassVault!',
            'timestamp' => date('Y-m-d H:i:s'),
        ]);
    }

    #[Route('/health', name: 'app_health')]
    public function health(): Response
    {
        return $this->json(['status' => 'healthy']);
    }
}
