# apps/integrations/views.py
import json
import hmac
import hashlib
import logging
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from .services import DialpadIntegrationService, SlackIntegrationService, BatsCRMIntegrationService
from ..shipping.services import ShippingCoordinatorService

logger = logging.getLogger(__name__)

@csrf_exempt
def dialpad_webhook(request):
    if request.method != 'POST':
        return JsonResponse({'status': 'error', 'message': 'Method not allowed'}, status=405)
    
    # Validate Dialpad signature if applicable
    
    try:
        data = json.loads(request.body)
        service = DialpadIntegrationService(settings.DIALPAD_CONFIG)
        processed_message = service.process_incoming_message(data)
        
        # Process with shipping coordinator
        coordinator = ShippingCoordinatorService()
        response = coordinator.process_message(processed_message)
        
        if response:
            service.send_response(
                destination=processed_message['context']['call_id'],
                message=response.get('message'),
                attachments=response.get('attachments')
            )
        
        return JsonResponse({'status': 'success'})
    except Exception as e:
        logger.error(f"Error processing Dialpad webhook: {str(e)}")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

@csrf_exempt
def slack_webhook(request):
    if request.method != 'POST':
        return JsonResponse({'status': 'error', 'message': 'Method not allowed'}, status=405)
    
    # Validate Slack signature
    slack_signing_secret = settings.SLACK_CONFIG.get('signing_secret', '')
    timestamp = request.headers.get('X-Slack-Request-Timestamp', '')
    signature = request.headers.get('X-Slack-Signature', '')
    
    # Signature validation code
    
    try:
        data = json.loads(request.body)
        
        # Handle Slack URL verification challenge
        if data.get('type') == 'url_verification':
            return JsonResponse({'challenge': data.get('challenge', '')})
            
        service = SlackIntegrationService(settings.SLACK_CONFIG)
        processed_message = service.process_incoming_message(data)
        
        # Process with shipping coordinator
        coordinator = ShippingCoordinatorService()
        response = coordinator.process_message(processed_message)
        
        if response:
            service.send_response(
                destination=processed_message['context']['channel'],
                message=response.get('message'),
                attachments=response.get('attachments')
            )
        
        return HttpResponse(status=200)
    except Exception as e:
        logger.error(f"Error processing Slack webhook: {str(e)}")
        return HttpResponse(status=500)

@csrf_exempt
def batscrm_webhook(request):
    if request.method != 'POST':
        return JsonResponse({'status': 'error', 'message': 'Method not allowed'}, status=405)
    
    # Validate BatsCRM webhook if needed
    
    try:
        data = json.loads(request.body)
        service = BatsCRMIntegrationService(settings.BATSCRM_CONFIG)
        processed_message = service.process_incoming_message(data)
        
        # Process with shipping coordinator
        coordinator = ShippingCoordinatorService()
        response = coordinator.process_message(processed_message)
        
        if response:
            service.send_response(
                destination=processed_message['context']['lead_id'],
                message=response.get('message'),
                attachments=response.get('attachments')
            )
        
        return JsonResponse({'status': 'success'})
    except Exception as e:
        logger.error(f"Error processing BatsCRM webhook: {str(e)}")
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
