/*
 * @author Kévin Melliand (kevin.melliand@tiime.fr)
 * @date 07/02/2019 (dd/mm/yyyy)
 * @description Mock Class allowing the test of http callout
 */
global class MockHttpResponse implements HttpCalloutMock {
	
	global HttpResponse respond(HttpRequest req) {return null;}
    
    global HTTPResponse respondDistanceMatrix(HTTPRequest req) {   	
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"destination_addresses" : ["15 Rue Auber, 75009 Paris, France","17 Place de la République, 49100 Angers, France"   ],   "origin_addresses" : [ "9th arrondissement of Paris, 75009 Paris, France" ],   "rows" : [      {         "elements" : [            {               "distance" : {                  "text" : "1.9 km",                  "value" : 1858               },               "duration" : {                  "text" : "9 mins",                  "value" : 533               },               "status" : "OK"            },            {               "distance" : {                  "text" : "300 km",                  "value" : 299640               },               "duration" : {                  "text" : "3 hours 4 mins",                  "value" : 11068               },               "status" : "OK"            }]}],"status" : "OK"}';
		res.setBody(body);
		return res;		
	}
	
	global HTTPResponse respondPlaceAutocomplete(HTTPRequest req) {   	
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"predictions" : [{"description" : "15 Rue Auber, Paris, France","id" : "132e24e774181f3736c097e01e0dc5671d7c5f12","matched_substrings" : [{"length" : 2,"offset" : 0},{"length" : 9,"offset" : 3},{"length" : 5, "offset" : 14},{"length" : 6,"offset" : 21}],"place_id" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","reference" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","structured_formatting" : {"main_text" : "15 Rue Auber","main_text_matched_substrings" : [{"length" : 2,"offset" : 0},{"length" : 9,"offset" : 3}],"secondary_text" : "Paris, France","secondary_text_matched_substrings" : [{"length" : 5,"offset" : 0},{"length" : 6,"offset" : 7}]},"terms" : [{"offset" : 0,"value" : "15" },{"offset" : 3,"value" : "Rue Auber"},{"offset" : 14,"value" : "Paris"},{"offset" : 21,"value" : "France"}], "types" : [ "street_address", "geocode" ]}],"status" : "OK"}';
		res.setBody(body);
		return res;		
	}
	
	global HTTPResponse respondPlaceDetails(HTTPRequest req) {   	
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"html_attributions" : [],"result" : {"address_components" : [{"long_name" : "15","short_name" : "15","types" : [ "street_number" ]},{"long_name" : "Rue Auber","short_name" : "Rue Auber","types" : [ "route" ]},{"long_name" : "Paris","short_name" : "Paris","types" : [ "locality", "political" ]},{"long_name" : "Paris","short_name" : "Paris","types" : [ "administrative_area_level_2", "political" ]},{"long_name" : "Île-de-France","short_name" : "Île-de-France","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "France","short_name" : "FR","types" : [ "country", "political" ]},{"long_name" : "75009","short_name" : "75009","types" : [ "postal_code" ]}],"adr_address" : "\u003cspan class=\"street-address\"\u003e15 Rue Auber\u003c/span\u003e, \u003cspan class=\"postal-code\"\u003e75009\u003c/span\u003e \u003cspan class=\"locality\"\u003eParis\u003c/span\u003e, \u003cspan class=\"country-name\"\u003eFrance\u003c/span\u003e","formatted_address" : "15 Rue Auber, 75009 Paris, France","geometry" : {"location" : {"lat" : 48.87272129999999,"lng" : 2.3284769},"viewport" : {"northeast" : {"lat" : 48.8741446802915,"lng" : 2.329919730291502},"southwest" : {"lat" : 48.8714467197085,"lng" : 2.327221769708498}}},"icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png","id" : "132e24e774181f3736c097e01e0dc5671d7c5f12","name" : "15 Rue Auber","place_id" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","plus_code" : {"compound_code" : "V8FH+39 Paris, France","global_code" : "8FW4V8FH+39"},"reference" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","scope" : "GOOGLE","types" : [ "street_address" ],"url" : "https://maps.google.com/?q=15+Rue+Auber,+75009+Paris,+France&ftid=0x47e66e3418d44b53:0xef7990bc97833cc1", "utc_offset" : 60,"vicinity" : "Paris"},"status" : "OK"}';
		res.setBody(body);
		return res;		
	}
	
    global HTTPResponse respondPlaceSuggestion(HTTPRequest req) {   	
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"predictions" : [{"description" : "15 Rue Auber, Paris, France","id" : "132e24e774181f3736c097e01e0dc5671d7c5f12","matched_substrings" : [{"length" : 2,"offset" : 0},{"length" : 9,"offset" : 3},{"length" : 5, "offset" : 14},{"length" : 6,"offset" : 21}],"place_id" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","reference" : "ChIJU0vUGDRu5kcRwTyDl7yQee8","structured_formatting" : {"main_text" : "15 Rue Auber","main_text_matched_substrings" : [{"length" : 2,"offset" : 0},{"length" : 9,"offset" : 3}],"secondary_text" : "Paris, France","secondary_text_matched_substrings" : [{"length" : 5,"offset" : 0},{"length" : 6,"offset" : 7}]},"terms" : [{"offset" : 0,"value" : "15" },{"offset" : 3,"value" : "Rue Auber"},{"offset" : 14,"value" : "Paris"},{"offset" : 21,"value" : "France"}], "types" : [ "street_address", "geocode" ]}],"status" : "OK"}';
		res.setBody(body);
		return res;		
	}
    
    global HTTPResponse respondCreateAccountFromLead(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"code":0,"erreur":"","numeroDossier":"00001"}';
		res.setBody(body);
		return res;
	}
	
	global HTTPResponse respondConvertLead(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"code":0,"erreur":"","url":"https://test.testons"}';
		res.setBody(body);
		return res;
	}
	
	global HTTPResponse respondGetOffres(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		String body = '{"code":0,"erreur":"","offres":"[]"}';
		res.setBody(body);
		return res;
	}
	
	global HTTPResponse respondGetAllNewLeads(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		
		String body = (req.getHeader('path') == 'none' ? 
		'<?xml version="1.0" encoding="UTF-8"?>' +
		'<demandes total="0" du="" au=""></demandes>' : 
		req.getHeader('path') == 'doublon' ? 
		 '<?xml version="1.0" encoding="UTF-8"?>' +
		'<demandes total="238" du="" au="">' +
    	'<demande>' +
        '<id>55681929540</id>' +
        '<lead_id>4809824</lead_id>' +
        '<dem_num>55681929540</dem_num>' +
        '<offer id="52669">' +
        '    <![CDATA[TIIME - Création d\'entreprise]]>' +
        '</offer>' +
        '<lead_date>08/02/2019</lead_date>' +
        '<raison_sociale>' +
        '    <![CDATA[Bodi]]>' +
        '</raison_sociale>' +
        '<civilite>MR</civilite>' +
        '<nom>' +
        '    <![CDATA[Bodi ]]>' +
        '</nom>' +
        '<prenom>' +
        '    <![CDATA[Youssef]]>' +
        '</prenom>' +
        '<code_postal>' +
        '    <![CDATA[75000]]>' +
        '</code_postal>' +
        '<ville>' +
        '    <![CDATA[Paris]]>' +
        '</ville>' +
        '<adresse>' +
        '    <![CDATA[ 7 rue de l l\'observance]]>' +
        '</adresse>' +
        '<email>dzegfvkblh@test.com</email>' +
        '<telephone>0732198123</telephone>' +
    '</demande>' +
    '</demandes>' :
		'<?xml version="1.0" encoding="UTF-8"?>' +
		'<demandes total="238" du="" au="">' +
    	'<demande>' +
        '<id>55681929540</id>' +
        '<lead_id>4809824</lead_id>' +
        '<dem_num>55681929540</dem_num>' +
        '<offer id="52669">' +
        '    <![CDATA[TIIME - Création d\'entreprise]]>' +
        '</offer>' +
        '<lead_date>08/02/2019</lead_date>' +
        '<raison_sociale>' +
        '    <![CDATA[Bodi]]>' +
        '</raison_sociale>' +
        '<civilite>MR</civilite>' +
        '<nom>' +
        '    <![CDATA[Bodi ]]>' +
        '</nom>' +
        '<prenom>' +
        '    <![CDATA[Youssef]]>' +
        '</prenom>' +
        '<effectif></effectif>' +
        '<activite code="Im">' +
        '    <![CDATA[Immobilier / B.T.P.]]>' +
        '</activite>' +
        '<poste code="OTHER">' +
        '    <![CDATA[]]>' +
        '</poste>' +
        '<fonction code="A">' +
        '    <![CDATA[Autres]]>' +
        '</fonction>' +
        '<code_postal>' +
        '    <![CDATA[75000]]>' +
        '</code_postal>' +
        '<ville>' +
        '    <![CDATA[Paris]]>' +
        '</ville>' +
        '<adresse>' +
        '    <![CDATA[ 7 rue de l l\'observance]]>' +
        '</adresse>' +
        '<adresse2>' +
        '    <![CDATA[]]>' +
        '</adresse2>' +
        '<adresse3>' +
        '    <![CDATA[]]>' +
        '</adresse3>' +
        '<email>dzegfvkblj@test.com</email>' +
        '<telephone>0732198645</telephone>' +
        '<fax></fax>' +
        '<mobile></mobile>' +
        '<commentaire>' +
        '    <![CDATA[pour faire évoluer son entreprise, a une micro et désir changer de statut<br/>]]>' +
        '</commentaire>' +
        '<internal_contact>' +
        '    <![CDATA[Grégoire CHARROYER]]>' +
        '</internal_contact>' +
        '<questionnaire>' +
        '    <question question_id="28178">' +
        '        <value>' +
        '            <![CDATA[Par quelle(s) prestation(s) êtes-vous intéressé ? ]]>' +
        '        </value>' +
        '        <reponse answer_id="15944">' +
        '            <![CDATA[Rédaction des statuts]]>' +
        '        </reponse>' +
        '        <reponse answer_id="15948">' +
        '            <![CDATA[Conseil sur le choix de la forme juridique]]>' +
        '        </reponse>' +
        '        <reponse answer_id="16885">' +
        '            <![CDATA[Publication de l’Annonce légale]]>' +
        '        </reponse>' +
        '        <reponse answer_id="16886">' +
        '            <![CDATA[Accompagnement auprès des organismes financiers pour demande de financement]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="26378">' +
        '        <value>' +
        '            <![CDATA[Sous quel délai votre société sera créée :]]>' +
        '        </value>' +
        '        <reponse answer_id="7029">' +
        '            <![CDATA[Dans le mois]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="25100">' +
        '        <value>' +
        '            <![CDATA[De quel apport personnel disposez-vous pour le démarrage de votre activité ?]]>' +
        '        </value>' +
        '        <reponse answer_id="480">' +
        '            <![CDATA[Moins de 2 000 € ]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="26486">' +
        '        <value>' +
        '            <![CDATA[Dans quel secteur d\'activité souhaitez-vous créer votre entreprise ?]]>' +
        '        </value>' +
        '        <reponse answer_id="8104">' +
        '            <![CDATA[BTP]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="27633">' +
        '        <value>' +
        '            <![CDATA[Expliquez en 1 phrase votre activité :]]>' +
        '        </value>' +
        '        <reponse>' +
        '            <![CDATA[travaux généraux  platre mur sols]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="25533">' +
        '        <value>' +
        '            <![CDATA[Quel est votre code postal actuel ?]]>' +
        '        </value>' +
        '        <reponse>' +
        '            <![CDATA[75000]]>' +
        '        </reponse>' +
        '    </question>' +
        '</questionnaire>' +
    '</demande>' +
    '<demande>' +
        '<id>5569192260</id>' +
        '<lead_id>4809820</lead_id>' +
        '<dem_num>5569192260</dem_num>' +
        '<offer id="52669">' +
        '    <![CDATA[TIIME - Démarches création d\'entreprise]]>' +
        '</offer>' +
        '<lead_date>08/02/2019</lead_date>' +
        '<raison_sociale>' +
        '    <![CDATA[Mr Luzumba ]]>' +
        '</raison_sociale>' +
        '<civilite>MR</civilite>' +
        '<nom>' +
        '    <![CDATA[Lu]]>' +
        '</nom>' +
        '<prenom>' +
        '    <![CDATA[In]]>' +
        '</prenom>' +
        '<effectif></effectif>' +
        '<activite code="">' +
        '    <![CDATA[]]>' +
        '</activite>' +
        '<poste code="PDG">' +
        '    <![CDATA[PDG, DG, Gérant]]>' +
        '</poste>' +
        '<fonction code="DG">' +
        '    <![CDATA[Direction Générale]]>' +
        '</fonction>' +
        '<code_postal>' +
        '    <![CDATA[93400]]>' +
        '</code_postal>' +
        '<ville>' +
        '    <![CDATA[Saint Ouen]]>' +
        '</ville>' +
        '<adresse>' +
        '    <![CDATA[7 RUE MOULOUD AOUNIT]]>' +
        '</adresse>' +
        '<adresse2>' +
        '    <![CDATA[]]>' +
        '</adresse2>' +
        '<adresse3>' +
        '    <![CDATA[]]>' +
        '</adresse3>' +
        '<email>andre.lu@test.com</email>' +
        '<telephone>0669875312</telephone>' +
        '<fax></fax>' +
        '<mobile></mobile>' +
        '<commentaire>' +
        '    <![CDATA[apres 16 h <br/>]]>' +
        '</commentaire>' +
        '<internal_contact>' +
        '    <![CDATA[Grégoire CHARROYER]]>' +
        '</internal_contact>' +
        '<questionnaire>' +
        '    <question question_id="28178">' +
        '        <value>' +
        '            <![CDATA[Par quelle(s) prestation(s) êtes-vous intéressé ? ]]>' +
        '        </value>' +
        '        <reponse answer_id="16886">' +
        '            <![CDATA[Accompagnement auprès des organismes financiers pour demande de financement]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="26378">' +
        '        <value>' +
        '            <![CDATA[Sous quel délai votre société sera créée :]]>' +
        '        </value>' +
        '        <reponse answer_id="7030">' +
        '            <![CDATA[D\'ici 1 à 3 mois ]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="25100">' +
        '        <value>' +
        '            <![CDATA[De quel apport personnel disposez-vous pour le démarrage de votre activité ?]]>' +
        '        </value>' +
        '        <reponse answer_id="481">' +
        '            <![CDATA[Entre 2 000 et 5 000 €]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="26486">' +
        '        <value>' +
        '            <![CDATA[Dans quel secteur d\'activité souhaitez-vous créer votre entreprise ?]]>' +
        '        </value>' +
        '        <reponse answer_id="8104">' +
        '            <![CDATA[BTP]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="27633">' +
        '        <value>' +
        '            <![CDATA[Expliquez en 1 phrase votre activité :]]>' +
        '        </value>' +
        '        <reponse>' +
        '            <![CDATA[electriciter]]>' +
        '        </reponse>' +
        '    </question>' +
        '    <question question_id="25533">' +
        '        <value>' +
        '            <![CDATA[Quel est votre code postal actuel ?]]>' +
        '        </value>' +
        '        <reponse>' +
        '            <![CDATA[93300]]>' +
        '        </reponse>' +
        '    </question>' +
        '</questionnaire>' +
    '</demande>' +
    '</demandes>');
		res.setBody(body);
		return res;
	}
}