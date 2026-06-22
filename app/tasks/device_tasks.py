"""
Background tasks for device operations
"""
import httpx
import json
from app.config import settings
import logging

logger = logging.getLogger(__name__)


def test_device_connection(device_id: int):
    """
    Test device connection in background
    Returns result to be displayed in modal
    """
    try:
        # Call the provisioner API
        with httpx.Client(timeout=60.0) as client:
            response = client.post(
                f"{settings.APOLLO_PROVISIONER_URL}/devices/{device_id}/test-connection"
            )
            
            if response.status_code == 200:
                result = response.json()
                return {
                    "status": "success",
                    "data": result,
                    "device_id": device_id
                }
            else:
                return {
                    "status": "error",
                    "message": f"Connection test failed with status {response.status_code}",
                    "detail": response.text,
                    "device_id": device_id
                }
                
    except Exception as e:
        logger.error(f"Error testing connection for device {device_id}: {e}")
        return {
            "status": "error",
            "message": "Connection test failed",
            "detail": str(e),
            "device_id": device_id
        }
