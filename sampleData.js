exampleData = {"berettiget": {
    "desc": "Er ansøgeren berettiget til at anmelde/ ansøge:",
    "info": "FVL indeholder ikke regler, hvem der som ansøger kan rejse en sag i den forstand, at myndigheden er forpligtet til at behandle og afgøre sagen. Der kan være særlige krav på specialområder. ",
    "questions": [
        { "text": "Har ansøgeren en tidsmæssigt aktuel retlig interesse i det resultat, som søges opnået gennem ansøgning?",
            "no": "afvisRet"},
        { "text": "Lever ansøgeren op til krav i speciallovgivningen som begrænser kredsen af ansøgere?",
            "no": "afvisRet"},
        { "text": "Er ansøgeren myndig eller vurderet til at være tilstrækkelig moden til at forstå konsekvenserne af sin ansøgning/ anmeldelse.",
            "no": "afvisRet"}
    ],
    "next": "formkravOk"
},
"formkravOk": {
    "desc": "Lever ansøgningen op til ansøgningens formkrav?",
    "info": "Der er et ulovbestemt krav til ansøgninger om skriftlighed, navn og underskrift. Ansøgningen skal indeholde hvad der anmeldes eller ansøges om. Forvaltningen har vejledningspligt til at afhjælpe evt. uklarheder jf. FVL § 7 stk. 1. Der er generelt adgang til at søge via email, digital signatur og kode tæller som underskrift, at afsenderen ansøger via email, tæller ikke som en underskrift. Hvis ansøgningen ikke er sendt til den rette del af den offentlige forvaltning har kommunen, så vidt muligt, pligt til at videresende sagen til rette myndighed jf. FVL § 7 stk. 2 Der kan være særlige formkrav i speciallovgivninger.",
    "questions": [
        { "text": "Fremgår anmeldelsens/ ansøgningen emne af ansøgningen?",
            "no": "formkravFejl"},
        { "text": "Fremgår ansøgerens navn og underskrift, kode eller digitale signatur af ansøgningen?",
            "no": "formkravFejl"},
        { "text": "Er ansøgningen tilsendt den myndighed der behandler ansøgninger på området?",
            "no": "videresend"}],
    "next": "Event 2"
}, 
"Event 2": {
    "desc": "Sagens forberedelse",
    "info": "..."
},
"afvisRet": {
    "decision": "Ansøgningen afvises pga. mangel på ret til at ansøge. Hvis afvisningen meddeles mundtligt, kan ansøgeren forlange en skriftlig begrundelse jf. FVL § 23 stk. 1, 1 pkt."},
"formkravFejl": {
    "decision": "Ansøgningen lever ikke op til de almindelige formkrav, hvorfor forvaltningen jf. FVL § 7 stk. 1 har vejledningspligt til at afhjælpe anmeldelsens/ ansøgningens uklarheder, hvis det er muligt at kontakte anmelderen/ ansøgeren. Ansøgeren har 14 dage til at afhjælpe ansøgningens mangler inden sagen afvises, men kan når som helst udfylde manglerne og ansøge igen."},
"videresend": {
    "decision": "Ansøgningen er ikke henvendt hos den rigtige del af forvaltningen og skal derfor, så vidt muligt videresendes til den korrekte myndighed jf. FVL § 7 stk. 2"}};
