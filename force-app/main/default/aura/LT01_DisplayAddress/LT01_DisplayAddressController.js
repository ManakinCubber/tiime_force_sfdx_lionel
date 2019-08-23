({
    initMap: function (cmp, event, helper) {
    	const lead = cmp.get("{!v.LeadObject}");
        cmp.set('v.mapMarkers', [
            {
                location: {
                    'Street': lead.Street,
                    'City': lead.City,
                    'Country': lead.Country,
                    'PostalCode': lead.PostalCode
                },
                title: '',
                description:''
            }
        ]);
        cmp.set('v.zoomLevel', 8);
    }
})