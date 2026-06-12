<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class DatabaseService
{
    protected Client $client;
    protected string $url;
    protected array $headers;

    public function __construct()
    {
        $this->url = config('supabase.SUPABASE_URL') . '/rest/v1/';

        $this->headers = [
            'apikey' => config('supabase.SUPABASE_KEY'),
            'Authorization' => 'Bearer ' . config('supabase.SUPABASE_KEY'),
            'Content-Type' => 'application/json',
            'Prefer' => 'return=representation'
        ];

        $this->client = new Client([
            'base_uri' => $this->url,
            'headers' => $this->headers
        ]);
    }

    // Get all data from the specified table
    public function getAllData(string $table, array $query = []): array
    {
        try {
            $response = $this->client->get($table, ['query' => $query]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }

    // Get data by column and value
    public function getDataBy(string $table, string $column, mixed $value): array
    {
        try {
            $response = $this->client->get($table, ['query' => [$column => 'eq.' . $value]]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }

    // Insert data into the specified table
    public function insertData(string $table, array $data): array
    {
        try {
            $response = $this->client->post($table, ['json' => $data]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }

    // Update data by column and value
    public function updateDataBy(string $table, string $column, mixed $value, array $data): array
    {
        try {
            $response = $this->client->patch($table, ['query' => [$column => 'eq.' . $value], 'json' => $data]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }


    // Delete data from by column and value
    public function deleteDataBy(string $table, string $column, mixed $value): array
    {
        try {
            $response = $this->client->delete($table, ['query' => [$column => 'eq.' . $value]]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }

    // Test the connection to the Supabase database
    public function testConnection(): array
    {
        try {
            $response = $this->client->get('', ['query' => ['limit' => 1]]);
            return ['status' => 'success', 'code' => $response->getStatusCode()];
        } catch (GuzzleException $error) {
            return ['status' => 'error', 'message' => $error->getMessage()];
        }
    }
}