/*
 * @author LUA Wailly (Wailly.lua@carrenet.com)
 * @date 14/09/2018 (dd/mm/yyyy)
 * @description Mock Class allowing the test of http callout from WS02_Chronos
 */
@isTest
global class MockHttpResponse_SendFile implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"id":626,"file_hash":"1wpEx_0tIqAdijHyDqbAkNddoKVtM9WZt","mime_type":"image/jpeg","comment":null}';
       	res.setBody(body);
        return res;
    }

    global HTTPResponse respondAuth(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        WS02_Chronos.tokenWrapper tokenWrapper = new WS02_Chronos.tokenWrapper();
        tokenWrapper.token ='eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlFqVkVORGM0TkRRNFJqTXhNREkxUkRoRU1UQXdSakJEUVVWR09UUTBNMFU0UlRFME1UQTFSQSJ9.eyJodHRwczovL3RpaW1lLmZyL25lZWRPbmJvYXJkaW5nIjp0cnVlLCJpc3MiOiJodHRwczovL3RpaW1lLmV1LmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw1YjhlMTNlMGZlMTMwOTBmNWZmZTU0N2IiLCJhdWQiOlsiaHR0cHM6Ly9jaHJvbm9zLWRldi8iLCJodHRwczovL3RpaW1lLmV1LmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE1MzcxODY4NTQsImV4cCI6MTUzNzI3MzI1NCwiYXpwIjoiM0RqYmxpc0oxdXNnUjBUREp1WWRaOXJRUzBHVHA1R3YiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIGFkZHJlc3MgcGhvbmUiLCJndHkiOiJwYXNzd29yZCJ9.RYDMHukAHaonEuiSFW4fjCtDIeI1ddtFYUO61SjGh7-tXgddNhPfxKVmkjNpx4THr-r0gPX2whZQHBxBVn-ApliL3uWj8L3KGdLvjtktaqJrJglt6kpKsmjkaXkjec3ITOcdaLOHnIaeX-buCOsLPrNSYJU2-49Xeq1wF0883PAdY2K0I0y2rrrwa9MPRfNQfG0cbv3ZvO5FfIZBxMuoEl1qNJkP9eMvP-DTr-7CkmGOdOFWd0ZEp2ybLeurmO7oCMdT7PdFIDMkYT80m6LCQZwbpe5eUl-UXoxH5h5VUqpAJ3LFHLPjBl8On_rYVuJmd9AXH9pJYHxGxZ3EYHFAng","id_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6ImFwaS5zYWxlc2ZvcmNlIiwibmFtZSI6ImFwaS5zYWxlc2ZvcmNlQHRpaW1lLmZyIiwicGljdHVyZSI6Imh0dHBzOi8vcy5ncmF2YXRhci5jb20vYXZhdGFyLzA4NTgxOTM2NTMxMjU0ZmZlNWRkMmUzMmU3ZDI0MTZkP3M9NDgwJnI9cGcmZD1odHRwcyUzQSUyRiUyRmNkbi5hdXRoMC5jb20lMkZhdmF0YXJzJTJGYXAucG5nIiwidXBkYXRlZF9hdCI6IjIwMTgtMDktMTdUMTI6MjA6NTQuNDY3WiIsImVtYWlsIjoiYXBpLnNhbGVzZm9yY2VAdGlpbWUuZnIiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vdGlpbWUuZXUuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDViOGUxM2UwZmUxMzA5MGY1ZmZlNTQ3YiIsImF1ZCI6IjNEamJsaXNKMXVzZ1IwVERKdVlkWjlyUVMwR1RwNUd2IiwiaWF0IjoxNTM3MTg2ODU0LCJleHAiOjE1MzcyMjI4NTR9.Pk8EbqCxTwmVcfxlOP6ojr5OgCAqx0GPKOc3SIR9QcQ';

        String body = JSON.serialize(tokenWrapper);
       	res.setBody(body);
        return res;
    }
}