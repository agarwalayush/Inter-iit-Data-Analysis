<?php

$hotel_name = "";
session_start();
function find_user($file, $hotel) {
    $f = fopen($file, "r");
    $result = false;
    while ($row = fgetcsv($f)) {
        if ($row[1] == $hotel) {
            $result = $row;
            break;
        }
    }
    fclose($f);
    return $result;
	}

if (isset($_POST['submit']) && (($_POST['hotel_name']) != "")) {
    $_SESSION['hotel_name'] = $_POST['hotel_name'];
	$res=find_user("hotel_table.csv", $_POST["hotel_name"]);
	$_SESSION['rating'] = $res[13];
	$_SESSION['travel'] = $res[4];
	$_SESSION['location'] = $res[5];
	$_SESSION['sleep_quality'] = $res[6];
	$_SESSION['rooms'] = $res[7];
	$_SESSION['distance'] = $res[8];
	$_SESSION['reviews'] = $res[9];
	$_SESSION['cleanliness'] = $res[10];
	
    header("Location: ". $_SERVER['REQUEST_URI']);
    exit;
} else {
    if(isset($_SESSION['hotel_name'])) {
        $hotel_name = $_SESSION['hotel_name'];
		$rating=$_SESSION['rating']*10;
		$travel=$_SESSION['travel']*10;
		$location=$_SESSION['location']*20;
		$sleep_quality=$_SESSION['sleep_quality']*20;
		$rooms=$_SESSION['rooms']*20;
		$distance=$_SESSION['distance']*20;
		$reviews=$_SESSION['reviews']*20;
		$cleanliness=$_SESSION['cleanliness']*20;
	
	
        unset($_SESSION['hotel_name']);
		unset($_SESSION['rating']);
		unset($_SESSION['travel']);
		unset($_SESSION['location']);
    }
}
?>
<head>
 <meta charset="utf-8">
  <title>IIT Kanpur- Inter IIT</title>
  <link rel="stylesheet" href="//code.jquery.com/ui/1.11.2/themes/smoothness/jquery-ui.css">
  <script src="//code.jquery.com/jquery-1.10.2.js"></script>
  <script src="//code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
  <link rel="stylesheet" href="/resources/demos/style.css">
  <script>
  $(function() {
    var availableTags = [
      "Grand Hyatt Goa", "Park Hyatt Goa Resort and Spa", "Country Inn & Suites By Carlson, Goa Candolim", "Vivanta by Taj - Panaji", "The LaLiT Golf & Spa Resort Goa", "16 Degrees North", "Santa Monica Resorte", "Fortune Select Regina", "Beleza...by the beach", "Jasminn by Mango Hotels", "The Park Calangute Goa", "Royal Palms", "Fahrenheit Hotels and Resorts", "Lazylagoon Sarovar Portico Suites", "Deltin Suites", "Radisson Blu Resort Goa Cavelossim Beach", "DoubleTree by Hilton Hotel Goa - Arpora - Baga", "Bogmallo Beach Resort", "Dona Sylvia Beach Resort", "Ondas do Mar Beach Resort", "Adamo The Bellus Goa", "Novotel Goa Shrem Resort", "Club Mahindra Varca Beach", "Cavala Seaside Resort", "Azzure By Spree Hotels", "Spazio Leisure Resort", "Alila Diwa Goa", "Acacia Goa", "Nazri Resort Hotel", "Nagoa Grande Hotel", "SinQ Beach Resort", "Casablanca", "The Golden Palms Hotel & Spa, Colva", "Nirvana Hermitage", "Resort Lagoa Azul", "Mira Hotel", "Varca Palms Beach Resort", "Golden Tulip Goa Candolim", "Calangute Residency", "Pride Sun Village Resort and Spa", "The O Hotel", "MAYFAIR Hideaway Spa Resort", "Rococco Ashvem", "Marquis Beach Resort", "The Baga Marina", "Sandalwood Hotel & Retreat", "Majorda Beach Resort", "10 Calangute", "Heritage Village Club Goa", "juSTa Panjim, Goa", "Kenilworth Resort & Spa", "Hotel Delmon", "Hotel Calangute Towers", "The Banyan Soul", "Renzo's Inn", "Royal Orchid Beach Resort & Spa, Goa", "Opus by the Verda", "Resorte Marinha Dourada", "Marbela Beach Resort", "Colonia Santa Maria (CSM)", "Banyan Tree Courtyard", "Acacia Palms Resort", "Royal Haathi Mahal", "Goa - Villagio, A Sterling Holidays Resort", "Montego Bay Beach Village", "Soul Vacation Resort and Spa", "Shanti Morada", "The HQ", "Highland Beach Resort", "Riva Beach Resort", "Hotel Bonanza", "Carina Beach Resort", "Hotel Colva Kinara", "The Crown Goa", "Grand Mercure Goa Shrem Resort", "Bougainvillea Guest House Goa", "Hotel Fidalgo", "Casa Vagator", "LivingRoom by Seasons", "Silver Sands Holiday Village", "Leoney Resort", "WelcomHeritage Panjim Inn", "The Fern Gardenia Resort, Canacona", "Sukhmantra Resort and Spa", "Sonesta Inns", "360 Degree Beach Retreat", "Country Inn & Suites By Carlson - Goa Panjim", "Godwin Hotel", "Best Western Devasthali Resort Goa", "Joecons Beach Resort", "Hotel Laguna Anjuna", "Victor Exotica Beach Resort", "Ruffles Beach Resort", "Vila Goesa Beach Resort", "La Sunila Clarks Inn Suites", "Graciano Cottages", "La Oasis by The Verda Anjuna", "Alegria - The Goan Village", "Amigo Plaza", "Mykonos Blu", "Hotel Santiago", "Aldeia Santa Rita", "Old Goa Residency", "Annapurna Vishram Dhaam", "Lambana Resort", "Palolem Inn", "Marigold", "Casa Colvale", "Joia Do Mar Resort", "Horizon", "Nilaya Hermitage", "The Diwa Club by Alila", "Celestiial Boutique Hotel", "Sapphire Comfort Hotel", "Prainha", "Hotel Astoria", "Martin's Comfort", "Lui Beach Resort", "Coconut Creek", "The Sofala", "L'Hotel Eden", "Chances Resort and Casino", "Coconut Grove", "Hotel Failaka", "Hotel La Capitol", "Banyan Tree Yoga Goa", "A's Holiday Beach Resort", "Safira River Front Resort", "Palacete Rodrigues", "Acron Waterfront Resort", "Kingstork Beach Resort", "Devaaya Ayurveda Retreat", "Abalone Resort", "Verca le Palms Beach Resort", "William's Beach Retreat", "Casa Britona", "Surya Sangolda", "The Ronil Royale", "Mobor Beach Resort", "All Season's Goa", "Pousada Tauma", "Sterling Goa India Days Inn", "Estrela Do Mar Beach Resort", "Empire Beach Resort Hotel", "Goa - Club Estadia, A Sterling Holidays Resort", "Longuinhos Beach Resort", "Baywatch Beach Resort", "Lotus Beach Resort", "The Byke Old Anchor Resort", "Aguada Hermitage", "Hotel Mandovi", "Farmagudi Residency", "Paradise Village Beach Resort", "Bambolim Beach Resort", "Calangute Annex", "Casa Baga", "Boomerang Resort", "Lua Nova Hotel", "Ticlo Resorts", "Alor Holiday Resort", "Sea Shore Beach Resort", "Seabreeze Resort", "Colonia de Braganza Resorts", "Prazeres Resorts", "Lucky Star Hotel", "Goveia Holiday Homes", "Colva Residency", "Maizons Lake View Resorts", "Mayem Lake View", "Goa Beach House", "Sun Park Resort", "Alor Grande Holiday Resort", "Hotel Dona Terezinha", "Colonia Jose' Menino Resort", "Hotel Surya Palace", "La Gulls Court", "Sharanam Green", "Alagoa Resort", "Hotel Supreme", "Gaffino's Beach Resort", "Resorte Beira Mar", "Summerville Beach Resort", "Riverside Guest House", "Sodder's Gloria Anne", "Resorte de Tio Carmino", "Panaji Residency", "Peninsula Beach Resort", "Valentines Retreat", "Resort Park Avenue", "Mapple Viva Goa", "Sodder's Renton Manor", "Maria Rosa Resort", "Sun City Resort", "Hotel Germany", "Hafh Resort", "Dolphin Bay Hotel", "Nizmar Resort", "Silver Sands Beach Resort", "Bollywood Sea Queen Beach Resort", "Resort Village Royale", "Hotel Miramar", "Hotel Viva Goa International", "Palm Resort", "Dona Alcina Resort", "Hotel Manvin's", "Avantika Resort", "Kris Resort", "The Zuri White Sands Goa Resort & Casino", "Resort Terra Paraiso", "Lemon Tree Amarante Beach Resort, Goa", "Vivanta by Taj - Fort Aguada, Goa", "Anup Holiday Homes", "Goa Marriott Resort & Spa", "Ramada Caravela Beach Resort", "Ocean Palms Goa", "De Alturas Resort", "The Leela Goa", "Neelams The Grand", "Palmarinha Resort", "Angels Resort", "Whispering Palms Beach Resort", "Santana Beach Resort", "Vivanta by Taj - Holiday Village, Goa", "Cidade de Goa", "Resort Rio", "Ancora Beach Resort", "Tangerine Resort", "North 16 Goa", "Citrus Goa", "The Tamarind Hotel", "Casa De Goa Boutique Resort", "Keys Resort-Ronil", "Casa Severina", "Ginger Goa", "Phoenix Park Inn Resort"
    ];
    $( "#tags" ).autocomplete({
      source: availableTags
    });
  });
  </script>
  
  <style type="text/css">
   
   #pun  {
		background-image: url('homepage.png');
		background-repeat: no-repeat;
		background-attachment: fixed;
		background-position: center;
		width:100%;
   }
   #content {
       z-index:1;
   }
   .ui-widget {
		position:absolute;
		top:40%;
		left: 50%;
		margin-left:-275px;
		width:550px;
   }
   #tags{
		width:432px;
   }
   #content{
		width:550px;
		background-color: #b0c4de;
		padding:10px;
		position:absolute;
		top:45%;
		left:50%;
		margin-left:-275px;
   }
</style>

<body id="pun">

 <form method="post">
<div class="ui-widget">
  Hotels: <input type="text" id="tags" name="hotel_name">

 <input class="go" type="submit" name="submit" value="Go">
 </div>
</form>
 


</body>
</head>
<?php

if($hotel_name != "") {
	
	$t=$travel."%";
	$l=$location."%";
	$s=$sleep_quality."%";
	$ro=$rooms."%";
	$d=$distance."%";
	$re=$reviews."%";
	$c=$cleanliness."%";
	$r=$rating."%";
    echo "<div id=\"content\"><b>Hotel Name :</b> $hotel_name <br>
	
	<b> Overall Stay Rating: </b> <span style=\"display: block; width: 65px; height: 13px; background: url(star-rating-sprite.png) 0 0;\">
    <span style=\"display: block; width: $r; height: 13px; background: url(star-rating-sprite.png) 0 -13px;\"></span>
</span>";
}
?>

</html>