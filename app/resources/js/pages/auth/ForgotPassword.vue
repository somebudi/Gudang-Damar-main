<script setup lang="ts">
import { Form, Head } from '@inertiajs/vue3';
import InputError from '@/components/InputError.vue';
import TextLink from '@/components/TextLink.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Spinner } from '@/components/ui/spinner';
import { login } from '@/routes';
import { email } from '@/routes/password';

defineOptions({
    layout: {
        title: 'Lupa Password',
        description: 'Masukkan email Anda untuk menerima tautan reset password',
    },
});

defineProps<{
    status?: string;
}>();
</script>

<template>
    <Head title="Lupa Password" />

    <div
        v-if="status"
        class="mb-4 text-center text-sm font-medium text-green-900"
    >
        {{ status }}
    </div>

    <div class="space-y-6">
        <Form v-bind="email.form()" v-slot="{ errors, processing }" class="bg-white/20 backdrop-blur-md border border-white/30 rounded-2xl shadow-xl p-8 flex flex-col gap-5">
            <div class="grid gap-2">
                <Label for="email">Alamat Email</Label>
                <Input
                    id="email"
                    type="email"
                    name="email"
                    autocomplete="off"
                    autofocus
                    placeholder="email@contoh.com"
                />
                <InputError :message="errors.email" />
            </div>

            <div class="my-3 flex items-center justify-start">
                <Button
                    class="w-full hover:bg-green-500 hover:text-white transition-colors"
                    :disabled="processing"
                    data-test="email-password-reset-link-button"
                >
                    <Spinner v-if="processing" />
                    Email Password Reset Link
                </Button>
            </div>
            <div class="space-x-1 text-center text-sm text-gray-800">
                <span>atau pergi ke</span>
                <TextLink :href="login()">log in</TextLink>
            </div>
        </Form>

    </div>
</template>
