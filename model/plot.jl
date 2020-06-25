"""
Plotting Functions
"""




"""
##################
PMAX=0.7
maxTEMP=30.0
maxKD=2.0
Res1 = simulate(LevelOfGrid=-1.0,pMax=PMAX, maxTemp=maxTEMP, backgrKd=maxKD)
Res2 = simulate(LevelOfGrid=-2.0,pMax=PMAX, maxTemp=maxTEMP, backgrKd=maxKD)
Res3 = simulate(LevelOfGrid=-3.0,pMax=PMAX, maxTemp=maxTEMP, backgrKd=maxKD)
Res4 = simulate(LevelOfGrid=-4.0,pMax=PMAX, maxTemp=maxTEMP, backgrKd=maxKD)



###########################################################################
### PLOTS
###########################################################################
Plots.scalefontsizes(2)
pyplot()
YEAR=1
maxBiomass=8100
maxN=20000
maxHeight=0.36
maxSeeds=1000

p1_1=plot(Res1[1][:,1,YEAR], label = 1, ylabel = "Biomass (g)", ylims=(0,maxBiomass), title="1m depth")
p1_2=plot(Res2[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="2m depth")
p1_3=plot(Res3[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="3m depth")
p1_4=plot(Res4[1][:,1,YEAR], label = 1, ylims=(0,maxBiomass), title="4m depth")

p2_1=plot(Res1[1][:,2,YEAR], label = 1, ylabel = "Individuals (N)", ylims=(0,maxN))
p2_2=plot(Res2[1][:,2,YEAR], label = 1, ylims=(0,maxN))
p2_3=plot(Res3[1][:,2,YEAR], label = 1, ylims=(0,maxN))
p2_4=plot(Res4[1][:,2,YEAR], label = 1, ylims=(0,maxN))

p3_1=plot(Res1[1][:,4,YEAR], label = 1, ylabel = "Height (m)", ylims=(0,maxHeight))
p3_2=plot(Res2[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))
p3_3=plot(Res3[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))
p3_4=plot(Res4[1][:,4,YEAR], label = 1, ylims=(0,maxHeight))

p4_1=plot(Res1[2][:,1,YEAR], label = 1, ylabel = "Seed biomass (g)", ylims=(0,maxSeeds), xlabel="Time (days)")
p4_2=plot(Res2[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")
p4_3=plot(Res3[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")
p4_4=plot(Res4[2][:,1,YEAR], label = 1, ylims=(0,maxSeeds), xlabel="Time (days)")


FIN=plot(p1_1,p1_2,p1_3,p1_4,
			#p2_1,p2_2,p2_3,p2_4,
			p3_1,p3_2,p3_3,p3_4,
			p4_1,p4_2,p4_3,p4_4,
		layout=(3,4), legend=false,size=(1400,1000)) #size=(800,600)

png("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\plot_all.png")

#Animation
Plots.scalefontsizes(0.8)
p = plot(1,layout = (2,4), label="")
anim = @animate for x=80:365
  #push!(p, 1, Res[1][x,1,5])
  plot!(p[1],  Res1[1][1:x,1,YEAR], ylabel="Plant Biomass (g)", ylims=(0,maxBiomass),label="", title="1m")
  plot!(p[2],  Res2[1][1:x,1,YEAR], label="", title="2m",ylims=(0,maxBiomass))
  plot!(p[3],  Res3[1][1:x,1,YEAR], label="", title="3m",ylims=(0,maxBiomass))
  plot!(p[4],  Res4[1][1:x,1,YEAR], label="", title="4m",ylims=(0,maxBiomass))

  #plot!(p[3],  Res1[1][1:x,2,5], ylabel="Plant individuals (N)", label="")
  #plot!(p[4],  Res2[1][1:x,2,5], label="")

  plot!(p[5],  Res1[1][1:x,4,YEAR], ylabel="Plant height (m)", label="", xlabel="Time (days)", ylims=(0,maxHeight))
  plot!(p[6],  Res2[1][1:x,4,YEAR], label="", xlabel="Time (days)", ylims=(0,maxHeight))
  plot!(p[7],  Res3[1][1:x,4,YEAR], label="", xlabel="Time (days)", ylims=(0,maxHeight))
  plot!(p[8],  Res4[1][1:x,4,YEAR], label="", xlabel="Time (days)", ylims=(0,maxHeight))

  #plot!(p[9],  Res1[2][1:x,1,YEAR], ylabel="Seeds Biomass (g)", label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  #plot!(p[10],  Res2[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  #plot!(p[11],  Res3[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
  #plot!(p[12],  Res4[2][1:x,1,YEAR], label="", xlabel="Time (days)", ylims=(0,maxSeeds))
end
#gif(C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\anim_1m,fps=5)
gif(anim,fps=5)



p1=plot(Res[1][:,1,1], label = 1, title = "Biomass")
for y in 2:settings["years"]
	display(plot!(Res[1][:,1,y], label = y))
end

p2=plot(Res[1][:,2,1], label = 1, title = "N")
for y in 2:settings["years"]
	display(plot!(Res[1][:,2,y], label = y))
end

p3=plot(Res[1][:,3,1], label = 1, title = "indWeight")
for y in 2:settings["years"]
	display(plot!(Res[1][:,3,y], label = y))
end
p4=plot(Res[1][:,4,1], label = 1, title = "height")
for y in 2:settings["years"]
	display(plot!(Res[1][:,4,y], label = y))
end
p5=plot(Res[1][:,5,1], label = 1, title = "allocatedBiomass")
for y in 2:settings["years"]
	display(plot!(Res[1][:,5,y], label = y))
end


#plot(Res[1][:,6], label = "SpreadFraction")

p6=plot(Res[2][:,1,1], label = 1, title = "SeedsBiomass")
for y in 2:settings["years"]
	display(plot!(Res[2][:,1,y], label = y))
end
p7=plot(Res[2][:,2,1], label = 1, title = "SeedsNR")
for y in 2:settings["years"]
	display(plot!(Res[2][:,2,y], label = y))
end
p8=plot(Res[2][:,3,1], label = 1, title = "SeedsGerminatingBiomass")
for y in 2:settings["years"]
	display(plot!(Res[2][:,3,y], label = y))
end


p9=plot(Res[3][:,1,1], label = 1, title = "PS Rate")
for y in 2:settings["years"]
	display(plot!(Res[3][:,1,y], label = y))
end
p10=plot(Res[3][:,2,1], label = 1, title = "Res Rate")
for y in 2:settings["years"]
	display(plot!(Res[3][:,2,y], label = y))
end

pfin = plot(p1,p2,p3,p4,p5,p6,p9,p10,layout=(4,2),legend=false)

png("C:\\Users\\anl85ck\\Desktop\\PhD\\4_Modellierung\\2_CHARISMA\\99_Figures\\plot_1m.png")





p = plot(1,layout = (4,1), label="")

anim = @animate for x=1:365
  #push!(p, 1, Res[1][x,1,5])
  plot!(p[2],  Res[1][1:x,1,5], title="Plant Biomass (g)", label="")
  plot!(p[3],  Res[1][1:x,2,5], title="Plant individuals (N)", label="")
  plot!(p[4],  Res[1][1:x,4,5], title="Plant height (m)", label="", xlabel="Time (days)")
  plot!(p[1],  Res[2][1:x,1,5], title="Seeds Biomass (g)", label="")
end
gif(anim,fps=5)


plt = plot(1, ylim=(0,2000),title = "Plant Biomass (g)", label="",xlabel="Time (days)")
ani = @animate for j=1:settings["years"]
		for i=1:settings["yearlength"]
			push!(plt, 1, Res[1][i,1,j])
	end
end
gif(ani, fps=1)

"""
