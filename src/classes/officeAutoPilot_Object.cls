global class officeAutoPilot_Object {
	public String id 					{get; set;}
	public String first_name 			{get; set;}
	public String last_name 			{get; set;}
	public String email 				{get; set;}
	public String home_phone 			{get; set;}
	public String title 				{get; set;}
	public String office_phone 			{get; set;}
	public String cell_phone 			{get; set;}
	public String fax 					{get; set;}
	public String company 				{get; set;}
	public String address 				{get; set;}
	public String address_2 			{get; set;}
	public String city 					{get; set;}
	public String state 				{get; set;}
	public String zip_code 				{get; set;}
	public String website 				{get; set;}
	public String country 				{get; set;}
	public String position 				{get; set;}
	public String guest_attending 		{get; set;}
	public String contact_owner			{get; set;}
	public String birthday 				{get; set;}
	public String person_type 			{get; set;}
	public String contact_id 			{get; set;}
	public String host_company 			{get; set;}
	public String referred_by 			{get; set;}
	public String number_of_guests 		{get; set;}
	public String sequences 			{get; set;}
	public String contact_tags 			{get; set;}	
	
	public officeAutoPilot_Object() {
		this.id 					= '';
		this.first_name 			= '';
		this.last_name 				= '';
		this.email 					= '';
		this.home_phone 			= '';
		this.title 					= '';
		this.office_phone 			= '';
		this.cell_phone 			= '';
		this.fax 					= '';
		this.company 				= '';
		this.address 				= '';
		this.address_2 				= '';
		this.city 					= '';
		this.state 					= '';
		this.zip_code 				= '';
		this.website 				= '';
		this.country 				= '';
		this.position 				= '';
		this.guest_attending 		= '';
		this.contact_owner			= '';
		this.birthday 				= '';
		this.person_type 			= '';
		this.contact_id 			= '';
		this.host_company 			= '';
		this.referred_by 			= '';
		this.number_of_guests 		= '';
		this.sequences 				= '';
		this.contact_tags 			= '';		
	}
	public static testMethod void officeAutoPilot_ObjectTest() {
		officeAutoPilot_Object obj = new officeAutoPilot_Object();
	}
}