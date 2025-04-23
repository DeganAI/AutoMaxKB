# apps/shipping/services.py
import logging
from django.conf import settings
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from ..models.services import ModelService  # Assuming MaxKB has a model service

class ShippingCoordinatorService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.model_service = ModelService()
    
    def process_message(self, message):
        """
        Process messages from various sources and generate appropriate shipping responses
        """
        self.logger.info(f"Processing message from {message['source']}")
        
        # Extract shipping-related intent from the message
        intent = self._extract_intent(message)
        
        if intent.get('type') == 'shipping_status':
            return self._handle_shipping_status(intent, message)
        elif intent.get('type') == 'new_shipment':
            return self._handle_new_shipment(intent, message)
        elif intent.get('type') == 'update_shipment':
            return self._handle_update_shipment(intent, message)
        else:
            # Default response for unrecognized intents
            return {
                'message': "I'm your shipping coordinator. You can ask me about shipping status, creating new shipments, or updating existing ones.",
                'attachments': None
            }
    
    def _extract_intent(self, message):
        """
        Use LLM to extract intent from user message
        """
        prompt = PromptTemplate(
            input_variables=["message"],
            template="""
            Analyze the following message and extract the shipping-related intent.
            Possible intents: shipping_status, new_shipment, update_shipment, other.
            
            Message: {message}
            
            Intent type:
            Tracking numbers (if any):
            Customer info (if any):
            Product info (if any):
            Special instructions (if any):
            """
        )
        
        llm_chain = LLMChain(
            llm=self.model_service.get_llm(),
            prompt=prompt
        )
        
        response = llm_chain.run(message=message['content'])
        
        # Parse response to extract structured intent data
        intent = self._parse_intent_response(response)
        return intent
    
    def _parse_intent_response(self, response):
        """Parse the LLM response into structured intent data"""
        lines = response.strip().split('\n')
        intent = {'type': 'other'}
        
        for line in lines:
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip().lower().replace(' ', '_')
                value = value.strip()
                intent[key] = value
        
        return intent
    
    def _handle_shipping_status(self, intent, message):
        """Handle shipping status inquiries"""
        # Here you would query your shipping database or API
        # For demonstration, we'll return a mock response
        tracking_numbers = intent.get('tracking_numbers', '')
        
        if tracking_numbers:
            return {
                'message': f"I found shipping status for tracking number(s) {tracking_numbers}. Your package is in transit and will be delivered by Thursday, April 24.",
                'attachments': [
                    {
                        'title': 'Shipment Details',
                        'fields': [
                            {'name': 'Status', 'value': 'In Transit'},
                            {'name': 'Estimated Delivery', 'value': 'April 24, 2025'},
                            {'name': 'Current Location', 'value': 'Distribution Center'}
                        ]
                    }
                ]
            }
        else:
            return {
                'message': "I couldn't find the tracking number in your message. Please provide a tracking number or order ID.",
                'attachments': None
            }
    
    def _handle_new_shipment(self, intent, message):
        """Handle creation of new shipments"""
        # Logic to create a new shipment in your system
        return {
            'message': "I've started processing your new shipment request. A shipping coordinator will finalize the details shortly.",
            'attachments': [
                {
                    'title': 'Shipment Request Received',
                    'fields': [
                        {'name': 'Customer', 'value': intent.get('customer_info', 'Not specified')},
                        {'name': 'Product', 'value': intent.get('product_info', 'Not specified')},
                        {'name': 'Special Instructions', 'value': intent.get('special_instructions', 'None')}
                    ]
                }
            ]
        }
    
    def _handle_update_shipment(self, intent, message):
        """Handle updates to existing shipments"""
        # Logic to update shipment in your system
        tracking_numbers = intent.get('tracking_numbers', '')
        
        if tracking_numbers:
            return {
                'message': f"I've updated shipment {tracking_numbers} with your new instructions. The changes will be reflected in the system shortly.",
                'attachments': None
            }
        else:
            return {
                'message': "I couldn't find which shipment you want to update. Please provide a tracking number or order ID.",
                'attachments': None
            }
