from machine import Pin, PWM, Timer
from time import sleep, sleep_us
import neopixel
import dht
import network
import ufirebase as firebase

# Connexion Wi-Fi
wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect("Wokwi-GUEST", "")  # Modifie avec ton SSID/pwd si besoin

while not wlan.isconnected():
    pass

print("Wi-Fi connecté!")

# Configuration Firebase
firebase.setURL("https://car-control-de6a4-default-rtdb.europe-west1.firebasedatabase.app/")

# Créer un objet Timer
timer = Timer(0) # Utiliser le Timer 0

#door buttons configuration
rd_button=Pin(21,Pin.IN) #Right door
ld_button=Pin(26,Pin.IN) #Left door
t_button=Pin(25,Pin.IN) #Trunk

#Ambient Light (lightring) configuration
NUM_LEDS = 16           
np = neopixel.NeoPixel(Pin(27), NUM_LEDS)

def fill_color(r, g, b):
    for i in range(NUM_LEDS):
        np[i] = (r, g, b)
    np.write()

def update_led_color():
    try:
        firebase.get("r", "r_data", bg=0)
        firebase.get("g", "g_data", bg=0)
        firebase.get("b", "b_data", bg=0)  # Récupère le dictionnaire RGB depuis Firebase
        print(f"Couleur reçue : R={firebase.r_data}, G={firebase.g_data}, B={firebase.b_data}")
        fill_color(firebase.r_data, firebase.g_data, firebase.b_data)  # Applique la couleur au light ring
    except:
        print("Erreur lors de la récupération de la couleur LED.")


# Configuration de DHT22
DHTsensor = dht.DHT22(Pin(14))

# Configuration des Headlights(LEDs)
RightHeadlight = Pin(17, Pin.OUT)
LeftHeadlight = Pin(16, Pin.OUT)

# Engine configuration(Stepper motor)
Engine_step_pin = Pin(32, Pin.OUT)
Engine_dir_pin = Pin(13, Pin.OUT)
def Engine_motor(steps, direction, delay_us=1000):
    Engine_dir_pin.value(direction)
    for _ in range(steps):
        Engine_step_pin.on()
        sleep_us(delay_us)
        Engine_step_pin.off()
        sleep_us(delay_us)

def check_engine_status():
    try:
        firebase.get("engine", "engine_status", bg=0)  # Récupère la valeur de "engine"
        if firebase.engine_status == "on":
            print("Moteur ON")
            for _ in range(5):  # Par exemple, 5 rotations
                Engine_motor(400, direction=1, delay_us=1000)
        elif firebase.engine_status == "off":
            print("🛑 Moteur OFF")
            step_pin.off()
            dir_pin.off()
    except:
        print("Erreur lors de la lecture de l'état du moteur.")

# AC configuration(Stepper motor)

step_pin = Pin(18, Pin.OUT)
dir_pin = Pin(19, Pin.OUT)
def step_motor(steps, direction, delay_us=1000):
    dir_pin.value(direction)
    for _ in range(steps):
        step_pin.on()
        sleep_us(delay_us)
        step_pin.off()
        sleep_us(delay_us)

# Configuration des portes(Servos)
servo_rd = PWM(12, freq=50) #Right door
servo_ld = PWM(22, freq=50) #Left door
servo_t = PWM(23, freq=50) #Trunk
# Fonction des portes
def set_angle(angle, servo_number):
    duty = int((angle / 180) * 102) + 26  # Ajustement pour 0.5 à 2 ms
    servo_number.duty(duty)

#fonction des portes
def read_servo_command(firebase_path, firebase_var, servo):
    try:
        firebase.get(firebase_path, firebase_var, bg=0)  # Lecture bloquante depuis Firebase
        state = getattr(firebase, firebase_var)          # Récupère dynamiquement la variable (ex: firebase.left_cmd)
        
        if state == "open":
            print(f"{firebase_var} : OPEN")
            set_angle(0, servo)
        elif state == "locked":
            print(f"{firebase_var} : CLOSE")
            set_angle(90, servo)
        elif state == "closed":
            print(f"{firebase_var} : ClOSE")
            set_angle(90, servo)
        else:
            print(f"{firebase_var} : Commande inconnue → {state}")
    except:
        print(f"Erreur lecture de {firebase_path}")

#fonction des phares
def update_headlights():
    try:
        firebase.get("lights", "hl_data", bg=0)  # Récupère l'état des phares depuis Firebase
        if (firebase.hl_data=="on") :
            LeftHeadlight.on()
            RightHeadlight.on()
        elif (firebase.hl_data=="off"):
            LeftHeadlight.off()
            RightHeadlight.off()            
    except:
        print("Erreur lors de la lecture des phares.")

def ac_on_off():
    firebase.get("ac", "ac_data", bg=0)
    if (firebase.ac_data == "on"):
        step_motor(400, direction=1, delay_us=1000)
    elif (firebase.ac_data == "off"):
        step_pin.off()

# Main code        
while True:
    try:
        read_servo_command("left_door", "left_cmd", servo_ld)
        read_servo_command("right_door", "right_cmd", servo_rd)
        read_servo_command("trunk", "trunk_cmd", servo_t)
        DHTsensor.measure() #To measure the temperature and humidity around the Driver
        temp = DHTsensor.temperature()
        print('Temperature: %3.1f C' % temp)
        firebase.put("temp", temp, bg=0)
        
        if (temp>28): #allume le AC si la temperature dépasse 28
            for i in range (5):
                step_motor(400, direction=1, delay_us=1000) 

        update_led_color() # example of the Ambient light(Lightring) in red
        update_headlights()
        check_engine_status()
        ac_on_off()
    except OSError as e:
        print('Failed to read sensor.')
