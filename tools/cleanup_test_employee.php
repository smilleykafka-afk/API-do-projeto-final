<?php

use App\Models\OrdemServico;
use App\Models\User;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;

// Local Docker smoke-test cleanup. Never select pre-existing staff by name alone.
require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
$id = $argv[1] ?? '';
$email = $argv[2] ?? '';
if (! ctype_digit($id) || ! preg_match('/^docker-[a-f0-9]{32}@example\.com$/D', $email)) {
    exit(1);
}
DB::transaction(function () use ($id, $email) {
    $user = User::whereKey($id)->where('email', $email)
        ->where('name', 'Docker smoke test')->where('role', 'employee')->lockForUpdate()->firstOrFail();
    if (OrdemServico::where('created_by', $id)->orWhere('assigned_to', $id)->exists()) {
        throw new RuntimeException('Temporary employee still has orders; cleanup refused.');
    }
    $user->tokens()->delete();
    $user->delete();
});
echo "Temporary smoke-test employee removed.\n";
