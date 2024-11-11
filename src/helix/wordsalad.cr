require "uuid"

module WordSalad
  WORDS = %w[come get give go keep let make put seem take be do have say see send may will about across after against among at before between by down from in off on over through to under up with as for of till than a the all any every little muffin much no other some such that this i he you who and because but or if though while how when where why again ever far forward here near now out still then there together well almost enough even not only quite so very tomorrow yesterday north south east west please yes 	account act addition adjustment advertisement agreement air amount amusement animal answer apparatus approval argument art attack attempt attention attraction authority back balance base behaviour belief birth bit bite blood blow body brass bread breath brother building burn burst business butter canvas care cause chalk chance change cloth coal colour comfort committee company comparison competition condition connection control cook copper copy cork cotton cough country cover crack credit crime crush cry current curve damage danger daughter day death debt decision degree design desire destruction detail development digestion direction discovery discussion disease disgust distance distribution division doubt drink driving dust earth edge 	education effect end error event example exchange existence expansion experience expert fact fall family father fear feeling fiction field fight fire flame flight flower fold food force form friend front fruit glass gold government grain grass grip group growth guide harbour harmony hate hearing heat help history hole hope hour humour ice idea impulse increase industry ink insect instrument insurance interest invention iron jelly join journey judge jump kick kiss knowledge land language laugh law lead learning leather letter level lift light limit linen liquid list look loss love machine man manager mark market mass meal measure meat meeting memory 	metal middle milk mind mine minute mist money month morning mother motion mountain move music name nation need news night noise note number observation offer oil operation opinion order organization ornament owner pastor page pain paint paper part paltry pastry paste payment peace person place plant play pleasure point poison polish porter position powder power price print process produce profit property prose protest pull punishment purpose push quality question rain range rate ray reaction reading reason record regret relation religion representative request respect rest reward rhythm rice river road roll room rub rule run salt sand scale science sea seat secretary selection self	sense servant sex shade shake shame shock side sign silk silver sister size sky sleep slip slope smash smell smile smoke sneeze snow soap society son song sort sound soup space stage start statement steam steel step stitch stone stop story stretch structure substance sugar suggestion summer support surprise swim system talk taste tax teaching tendency test theory thing thought thunder time tin top touch trade transport trick trouble turn twist unit use value verse vessel view voice walk war wash waste water wave wax way weather week weight wind wine winter woman wood wool word work wound writing year 	angle ant apple arch arm army baby bag ball band basin basket bath bed bee bell berry bird blade board boat bone book boot bottle box boy brain brake branch brick bridge brush bucket bulb button cake camera card cart carriage cat chain cheese chest chin church circle clock cloud coat collar comb cord cow cup curtain cushion dog door drain drawer dress drop ear egg engine eye face farm feather finger fish flag floor fly foot fork fowl frame garden girl glove goat gun hair hammer hand hat head heart hook horn horse hospital house island jewel kettle key	knee knife knot leaf leg library line lip lock map match monkey moon mouth muscle nail neck needle nerve net nose nut office orange oven parcel pen pencil picture pig pin pipe plane plate plough pocket pot potato prison pump rail rat receipt ring rod roof root sail school scissors screw seed sheep shelf ship shirt shoe skin skirt snake sock spade sponge spoon spring square stamp star station stem stick stocking stomach store street sun table tail thread throat thumb ticket toe tongue tooth town train tray tree trousers umbrella wall watch wheel whip whistle window wing wire worm 	able acid angry automatic beautiful black boiling bright broken brown cheap chemical chief clean clear common complex conscious cut deep dependent early elastic electric equal fat fertile first fixed flat free frequent full general good great grey hanging happy hard healthy high hollow important kind like living long male married material medical military natural necessary new normal open parallel past physical political poor possible present private probable quick quiet ready red regular responsible right round same second separate serious sharp smooth sticky stiff straight strong sudden sweet tall thick tight tired true violent waiting warm wet wide wise yellow young batter]
  DEFAULT_SIZE = 5
  MAX_SIZE = 13
  
  def self.from_i(n : Int)
    n128 = n.to_u128

    n0 = n128 & Int32::MAX
    n1 = (n128 & (Int32::MAX << 1)) >> 1
    n2 = (n128 & (Int32::MAX << 2)) >> 2
    n3 = (n128 & (Int32::MAX << 3)) >> 3

    "#{WORDS[n0 % WORDS.size]}.#{WORDS[n1 % WORDS.size]}.#{WORDS[n2 % WORDS.size]}.#{WORDS[n3 % WORDS.size]}"
  end

  def self.random(n = DEFAULT_SIZE)
    words = [] of String
    n.times do |n|
      words << WORDS[rand(WORDS.size)]
    end
    words.join(".")
  end

  def self.from_uuid(uuid : UUID)
    o = 0_u128
    uuid.bytes.each_with_index do |b, i|
      o += b << i
    end
    from_i(o)
  end

  class Generator(N)
    alias Default = Generator(DEFAULT_SIZE)
    @current : StaticArray(UInt32, N) = StaticArray(UInt32, N).new(0_u32)

    def next : String
      words = [] of String
      N.times do |n|
        # Pulls the words out using the current values
        words << WORDS[@current[(N-1)-n]]
      end

      # Increment @current w/ overflow
      @current[0] += 1
      x = 0
      while @current[x] >= WORDS.size && x < N
        @current[x] = 0
        raise "Overflow" if x+1 >= N
        @current[x+1] += 1
        x += 1
      end

      words.join(".")
    end

    def random
      WordSalad.random(N)
    end


    def total : UInt128
      WORDS.size.to_u128 ** N
    end
  end
end

struct UUID
  def to_human
    WordSalad.from_uuid(self)
  end
end