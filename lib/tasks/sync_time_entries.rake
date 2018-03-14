namespace :hr do
	task :sync_time_entries => :environment do
		date = '2018-01-01'
		users_id = User.where("login IN (?)", ['aaaraya','aabad','aaguilar','aaguilera','aamunoz','aarmenta','abarrio','abarroso','aberdugo','abgalan','acabrerizo','acosanchez','acovenas','adpaulo','afconceglieri','afolvera','agaliano','agallego','agarcia','agarrido','agdominguez','agiraldez','agmoreno','agonzalez','agramirez','agrillo','aiekeler','aiguerrero','aimunoz','ajalfonzo','ajmantis','ajrios','akrio','alao','aleon','almontoya','aluna','aluque','amaparicio','amartinez','amartinzarco','ambullon','amcantero','amescano','amgarcia','amoron','amunoz','anavarro','anavarro','anavas','apizarro','aromo','arpernalete','asierra','avallejo','aypena','bbermudo','bcrampersad','bcura','bgomez','bgonzalez','bpasquale','bshcherbak','bsomville','caalamos','cacortes','canavarrete','carmario','cbonilla','cdominguez','cdoyarzun','cfierro','cjimenez','cmelero','cmtomaduz','cmvicencio','cparra','cpcalderon','cperera','cpinto','craigada','crgonzalez','cromero','csegura','csevillano','ctarifeno','ctorrejon','cvelazquez','damunoz','dapradenas','darellano','dcaro','dggarcia','dgmunoz','dlopez','dlozano','dmesa','dmorillo','dmoyano','dmsanchez','dmunarriz','doliver','dortega','dperez','dpineda','drmunoz','dvidela','eacuna','eaguerrero','easandez','ebalbuena','ebarrera','ebartolome','ecriado','ecruz','efernandez','ehernandez','elgarcia','elopez','emvega','emvera','eperez','equiroz','esilva','evargas','faabreu','fafranco','famasa','farrieche','fasallato','fbaena','fdayoub','fesepulveda','ffarrabal','fgcordero','Fimunoz','fjacuna','fjbarrera','fjcortes','fjgarcia','fjmartinez','fjmayorga','fjmimbrera','fjramirez','flopez','fmmedina','fmorales','fmquiroga','fmrodriguez','fpanea','fperez','fprodriguez','frodriguez','gapino','ggdiaz','ghsanchez','gmarguart','gmunoz','gsalguero','hagonzalez','hcastro','hfiel','hleal','hmateo','hmsalvatierra','ialberni','icabello','iespin','igalafate','igomez','igonzalez','iherrera','iiglesias','ijimenez','ijramones','ilopez','imaliaga','imateo','imontoya','ipinto','iponce','ircasado','irey','iwsalvador','jabolton','jacarvajal','jachica','jadorado','jagallego','jagarrido','jagranados','jaguirre','jalaganga','jalcaniz','jamarillo','jamores','jaresurreccion','jariera','jarroyo','jaruiz','jasanchez','jcalvarado','jcanales','jcarmona','jccarrasco','jccastro','jcfernandez','jcgonzalez','jchierro','jcmoreno','jcolmenarez','jcorral','jcuendes','jdamigo','jdcabra','jdiaz','jdionisio','jebarba','jgamero','jgnavarro','jgonzalez','jharana','jherrera','jicano','jjegea','jjgonzalez','jjimenez','jjpaz','jjprieto','jjteixeira','jjtrigo','jlago','jlguillen','jlibic','jlozano','jlsanchez','jmcaceres','jmcardozo','jmfernandez','jmferrer','jmgarcia','jmglopez','jmmarquez','jmontilla','jmoreno','jmoreno','jmsotomayor','jmurcia','jnavas','jpacheco','jparrilla','jpeinado','jppena','jpromana','jrcayetano','jrelinque','jresinas','jrivas','jrlopez','jroldan','jsolis','jzambrana','kagutierrez','kjuarez','lacartaya','lalbea','lalonso','lapetit','lborrego','lcarbajo','ldcontreras','lespinoza','lgarrido','lgcorredera','lizamora','llopez','lmparra','lmreyes','lreyes','lromero','lxtorres','macoronado','mafont','magerman','maguilera','majimenez','marcos','masalinas','mavillalba','mbarriento','mbermejo','mcaliani','mcamacho','mcgordillo','mcluque','mcorzetto','mdgonzalez','mdrabaez','mescudero','mfeijoo','mfgallego','mgimenez','mgvillamarin','miacevedo','migomez','mjgonzalez','mjgrodriguez','mjimenez','mjpalmero','mjpascual','mjsantos','mlcardona','mlopez','mlourdes','mltarifeno','mmaturana','mnaranjo','mpfranco','mromero','msanchez','msrodriguez','mufano','mvaliente','mvchacon','naoportus','nblanco','nemorales','nguerrero','nhumberto','ocastano','ofgundurraga','ogonzalez','olara','omontero','pareyes','pbarroso','pchoza','pclemente','pcuellar','pfernandez','pfgarcia','pgil','piglesias','pjimenez','pjralil','plloret','pmsobrado','pracamonde','pramos','prarce','prodriguez','prodriguez','projas','psacaluga','rafuentes','ragonzalez','rarangel','raroca','ratorres','ratroncoso','rbecerra','rcarballo','rchaparro','rcmorano','rdroguett','rexposito','rferreras','rfranco','rgbravo','rhurtado','rjnogueroles','rmartin','rmelo','rmhernandez','rmontero','rmoreno','rmtorres','rramos','rrico','rrparada','rsalinas','rserrano','rtorres','rtoscano','sarocha','sgarcia','sjara','sluna','smata','smovalles','smrojas','sportillo','sportillo','sramirez','sromero','sserrano','storo','svega','vagallardo','varce','vaverdejo','vfernandez','vhmartin','vhmunoz','vlopez','vrico','wjnodas','yeconcha']).map(&:id)

		puts "Delete profiles and costs"
		TimeEntry.where("user_id IN (?) AND spent_on >= ?", users_id, date).update_all("hr_profile_id = NULL, cost = 0.0")

		puts "Get last time entry"
		last_date = (last_time_entry = TimeEntry.order('spent_on DESC').first).present? ? 
	      last_time_entry.spent_on :
	      Date.today

	    puts "Get array of hourly costs by profile"
	    hourly_costs_profile = {}
	    HrProfile.all.each do |p|
	    	hourly_costs_profile[p.id] = p.costs.inject({}){|h, c| h[c.year] = c.hourly_cost; h}
	    end

		puts "Set correct profile and cost"
		# User.all.each do |u|
		# 	puts "User: ##{u.id}: #{u.login}"

		# end
		HrUserProfile.where("user_id IN (?) AND start_date >= ?", users_id, date).each do |hup|
			puts "HUP: #{hup.id}"
			(date.to_date.year..(hup.end_date || last_date).year).each do |year|
			  max_year = HrProfilesCost.maximum(:year)
		      hourly_cost = hup.hr_profile_id.present? ? hourly_costs_profile[hup.hr_profile_id][[year, max_year].min] : 0.0
		      profile = hup.hr_profile_id.present? ? hup.hr_profile_id : "NULL"
		      hup.time_entries.where(tyear: year).update_all("hr_profile_id = #{profile}, cost = (#{hourly_cost} * hours)")
		    end
		end
	end

end