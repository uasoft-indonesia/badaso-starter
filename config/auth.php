<?php
return [
    'defaults' => [
        'guard' => 'badaso_guard',
        'passwords' => 'users',
    ],
    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],
        'badaso_guard' => [
            'driver' => 'jwt',
            'provider' => 'badaso_users',
        ],
    ],
    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => 'App\\Models\\User',
        ],
        'badaso_users' => [
            'driver' => 'eloquent',
            'model' => 'Uasoft\\Badaso\\Models\\User',
        ],
    ],
    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_resets',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],
    'password_timeout' => 10800,
] ;