import json
import logging
import os
import azure.functions as func

from azure.identity import DefaultAzureCredential
from azure.storage.queue import QueueClient


QUEUE_NAME = os.environ["QUEUE_NAME"]
STORAGE_ACCOUNT_URL = os.environ["STORAGE_ACCOUNT_URL"]


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Received provisioning request")

    try:
        payload = req.get_json()
    except ValueError:
        return func.HttpResponse(
            "Invalid JSON body",
            status_code=400
        )

    required_fields = ["ticketId", "userPrincipalName", "displayName"]
    missing = [f for f in required_fields if f not in payload]

    if missing:
        return func.HttpResponse(
            f"Missing required fields: {', '.join(missing)}",
            status_code=400
        )

    credential = DefaultAzureCredential()

    queue_client = QueueClient(
        account_url=STORAGE_ACCOUNT_URL,
        queue_name=QUEUE_NAME,
        credential=credential
    )

    queue_client.send_message(json.dumps(payload))

    logging.info(
        "Request enqueued for ticket %s",
        payload["ticketId"]
    )

    return func.HttpResponse(
        json.dumps({
            "status": "accepted",
            "ticketId": payload["ticketId"]
        }),
        status_code=202,
        mimetype="application/json"
    )
