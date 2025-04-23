# apps/shipping/models.py
from django.db import models

class ShipmentStatus(models.TextChoices):
    CREATED = 'created', 'Created'
    PROCESSING = 'processing', 'Processing'
    SHIPPED = 'shipped', 'Shipped'
    IN_TRANSIT = 'in_transit', 'In Transit'
    DELIVERED = 'delivered', 'Delivered'
    EXCEPTION = 'exception', 'Exception'

class Shipment(models.Model):
    tracking_number = models.CharField(max_length=100, unique=True)
    external_id = models.CharField(max_length=100, blank=True, null=True)
    customer_name = models.CharField(max_length=255)
    customer_email = models.EmailField()
    customer_phone = models.CharField(max_length=20, blank=True, null=True)
    
    # Address details
    address_line1 = models.CharField(max_length=255)
    address_line2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    country = models.CharField(max_length=100, default='United States')
    
    # Shipment details
    carrier = models.CharField(max_length=100)
    service_level = models.CharField(max_length=100)
    status = models.CharField(
        max_length=20,
        choices=ShipmentStatus.choices,
        default=ShipmentStatus.CREATED
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    estimated_delivery_date = models.DateField(blank=True, null=True)
    actual_delivery_date = models.DateField(blank=True, null=True)
    
    # Special instructions
    special_instructions = models.TextField(blank=True, null=True)
    
    # Metadata
    source = models.CharField(max_length=50, help_text="Source system (dialpad, slack, batscrm, etc)")
    source_id = models.CharField(max_length=100, blank=True, null=True, help_text="ID in the source system")
    
    def __str__(self):
        return f"{self.tracking_number} - {self.customer_name} ({self.status})"

class ShipmentItem(models.Model):
    shipment = models.ForeignKey(Shipment, related_name='items', on_delete=models.CASCADE)
    product_name = models.CharField(max_length=255)
    product_sku = models.CharField(max_length=100)
    quantity = models.PositiveIntegerField(default=1)
    weight = models.FloatField(blank=True, null=True)
    weight_unit = models.CharField(max_length=10, default='kg')
    
    def __str__(self):
        return f"{self.product_name} (x{self.quantity})"

class ShipmentEvent(models.Model):
    shipment = models.ForeignKey(Shipment, related_name='events', on_delete=models.CASCADE)
    status = models.CharField(max_length=100)
    location = models.CharField(max_length=255, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField()
    
    class Meta:
        ordering = ['-timestamp']
    
    def __str__(self):
        return f"{self.status} at {self.timestamp}"
