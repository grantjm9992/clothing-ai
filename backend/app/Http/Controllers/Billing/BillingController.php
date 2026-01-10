<?php

namespace App\Http\Controllers\Billing;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use Illuminate\Http\Request;

class BillingController extends Controller
{
    public function verify(Request $request)
    {
        $validated = $request->validate([
            'provider' => 'required|in:apple,google,stripe',
            'receipt' => 'required|string',
        ]);

        $user = $request->user();

        // TODO: Implement actual receipt verification with provider APIs
        // For now, create a basic subscription

        $subscription = Subscription::updateOrCreate(
            [
                'user_id' => $user->id,
                'provider' => $validated['provider'],
            ],
            [
                'status' => 'active',
                'current_period_end' => now()->addMonth(),
            ]
        );

        return response()->json([
            'subscription' => $subscription,
            'message' => 'Subscription verified',
        ]);
    }

    public function status(Request $request)
    {
        $user = $request->user();

        $activeSubscription = $user->subscriptions()
            ->whereIn('status', ['active', 'trialing'])
            ->first();

        return response()->json([
            'hasActiveSubscription' => $user->hasActiveSubscription(),
            'subscription' => $activeSubscription,
        ]);
    }
}
