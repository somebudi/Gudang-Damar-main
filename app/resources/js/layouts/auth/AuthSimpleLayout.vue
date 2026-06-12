<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { home } from '@/routes';

defineProps<{
    title?: string;
    description?: string;
}>();
</script>

<template>
    <div class="relative min-h-svh flex items-center justify-center p-6 md:p-10">

        <div
            class="absolute inset-0 bg-cover bg-center blur-[3px] scale-110"
            :style="{ backgroundImage: 'url(/gambar/background.jpg)' }"
        ></div>

        <div class="relative w-full max-w-sm">
            <div class="flex flex-col gap-8">
                <div class="flex flex-col items-center gap-4">
                    <Link
                        :href="home()"
                        class="flex flex-col items-center gap-2 font-medium"
                    >
                        <div class="mb-1 flex h-20 w-20 items-center justify-center rounded-md">
                            <img src="/gambar/LogoDamar.jpeg" alt="Logo" class="size-full object-cover" />
                        </div>
                        <span class="sr-only">{{ title }}</span>
                    </Link>

                    <div class="space-y-2 text-center">
                        <h1 class="text-xl font-medium">{{ title }}</h1>
                        <p class="text-sm text-muted-foreground">
                            {{ description }}
                        </p>
                    </div>
                </div>

                <slot />
            </div>
        </div>
    </div>
</template>
