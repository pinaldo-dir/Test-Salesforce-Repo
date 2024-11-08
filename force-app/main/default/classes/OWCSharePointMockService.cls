@IsTest
global class OWCSharePointMockService implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"sharePointDocumentId":"01GQWYHAWO6N3X2DAYBBF3HZHGEVJIGYWT","downloadURL":"https://cadir.sharepoint.com/sites/OISSFDCFiles/_layouts/15/download.aspx?UniqueId=7d77f3ce-180c-4b08-b3e4-e625528362d3&Translate=false&tempauth=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvY2FkaXIuc2hhcmVwb2ludC5jb21AMDJkMDA0MGUtMTM0OC00YzVlLTg2ZTQtMGE1YWU4ZWRlOWQ2IiwiaXNzIjoiMDAwMDAwMDMtMDAwMC0wZmYxLWNlMDAtMDAwMDAwMDAwMDAwIiwibmJmIjoiMTY1NzA5ODkxNyIsImV4cCI6IjE2NTcxMDI1MTciLCJlbmRwb2ludHVybCI6InBrYjc0T0lwaEJ1ZFNoaWhYUnFKSVhNMUdqa0UvNTdaSUg4YVQzT3U5NDQ9IiwiZW5kcG9pbnR1cmxMZW5ndGgiOiIxMzUiLCJpc2xvb3BiYWNrIjoiVHJ1ZSIsImNpZCI6Ik56UXpNREJtWlRJdE1qRTFNeTAwT0RCaUxUZzNOekl0TnpRNU16ZG1aREppWlRaayIsInZlciI6Imhhc2hlZHByb29mdG9rZW4iLCJzaXRlaWQiOiJObVExWkdWak5UTXROR1JqTVMwME0yRXdMV0k1TTJFdFl6VTVZbVl4TlRrek1XUXgiLCJhcHBfZGlzcGxheW5hbWUiOiJESVJfU2hhcmVQb2ludCIsIm5hbWVpZCI6IjkzMjU2YzMwLTkyOGMtNGM3Ni05MjE5LTZhMzZlZTJkYjM2ZEAwMmQwMDQwZS0xMzQ4LTRjNWUtODZlNC0wYTVhZThlZGU5ZDYiLCJyb2xlcyI6InNoYXJlcG9pbnR0ZW5hbnRzZXR0aW5ncy5yZWFkd3JpdGUuYWxsIHNoYXJlcG9pbnR0ZW5hbnRzZXR0aW5ncy5yZWFkLmFsbCBhbGxmaWxlcy53cml0ZSBhbGxmaWxlcy5yZWFkIiwidHQiOiIxIiwidXNlUGVyc2lzdGVudENvb2tpZSI6bnVsbCwiaXBhZGRyIjoiNDAuMTI2LjI2LjMyIn0.VWF1RnhKL0hRTVRyTVlSTDIycUNhNXFYbjI1QVhuN2o1NkRlMVBlVWRGQT0&ApiVersion=2.0"}]');
        response.setStatusCode(201);
        return response;
    }
}