__includes ["setup.nls"]
            
globals [
  AllHouseholds                                                                                                     ;; agentset for households patches (all patches except borders)
  UniversityStaff                                                                                                   ;; agentset for university households
  LocalResidents                                                                                                    ;; agentset for local villager households
  IndependentResidents                                                                                              ;; agentset for independent housing
  Containers                                                                                                        ;; agentset for containers
  border-color                                                                                                      ;; every color is saved into global to avoid having to change a lot when colors change
  Container-color
  Collector-color
  Landfill-color
  PhysicalContainer-color
  BroughtToContainer                                                                                                ;; is the summation of all waste brought to containers
  CollectedRecyclates                                                                                               ;; is the summation of all waste given to collectors
  LandfillWaste                                                                                                     ;; is the summation of all waste for the landfill
  ParticipationRateContainer
  ParticipationRateCollector
  ParticipationRateLandfill
  WasteTreshold                                                                                                     ;; when this treshold is exceeded, the waste is disposed
  MinutesPerHour
  HoursPerWeek
  WeeksPerYear  
  BaseIncomeLvl3                                                                                                    ;; the base of the income of education level 3. Randomness comes on top of this
  BaseIncomeLvl2                                                                                                    ;; the base of the income of education level 2. Randomness comes on top of this
  BaseIncomeLvl1                                                                                                    ;; the base of the income of education level 1. Randomness comes on top of this
  BaseLvl3                                                                                                          ;; the base of awareness and recycling knowledge of education level 3. Randomness comes on top of this
  BaseLvl2                                                                                                          ;; the base of awareness and recycling knowledge of education level 2. Randomness comes on top of this
  BaseLvl1                                                                                                          ;; the base of awareness and recycling knowledge of education level 1. Randomness comes on top of this
  MaxFriends                                                                                                        ;; the maximum amount of friends in list social network
  ChanceOfFriendsInOwnZone                                                                                          ;; the chance that a friend is in your own zone
  ]

patches-own[
  HouseholdSize
  Income
  Zone
  Networksize
  SocialNetwork
  NearestContainer                                                                                                  ;; the nearest container used to dispose of garbage
  ContainerRequiredTime                                                                                             ;; the time a household needs to use a container
  CollectorRequiredTime                                                                                             ;; the time a household needs to give recyclates to a collector  
  CollectorRequiredSpace                                                                                            ;; the space a household needs to store recyclates for collectors
  AvailableTime                                                                                                     ;; the amount of time a household is willing/able to spend recycling
  AvailableSpace                                                                                                    ;; the amount of space a household has to put away recyclate bags
  AmountOfWaste                                                                                                     ;; the amount of waste that is currently inside the households
  EducationLevel
  RecyclingAwareness
  RecyclingKnowledge  
  WillingnessToChange
  Attitude
  SocialNorm
  PerceivedBehaviouralControl
  Intention                                                                                                         ;; the intention of households, whether they want to recycle
  RecyclingBehaviour                                                                                                ;; the actual behaviour of households, whether they recycle their waste
  ]

to Setup
  clear-all
  reset-ticks
  
  random-seed 1 
  
  resize-world -50 50 -50 50
  set-patch-size 7.515 
  
  if MinimalTesting = true [
  minimal-test ]

  determine-colors                                                                                                  ;; in this procedure, the colors of the border and different patches is determined, see setup.nls
  determine-borders                                                                                                 ;; in this procedure, the actual borders are determined, see setup.nls
  determine-containers
  determine-patch-sets                                                                                              ;; in this procedure, the patchsets are determined to make it easier to ask certain groups, see setup.nls
  determine-constants
  determine-initial-waste                                                                                           ;; in this procedure, the initial waste of the households is determined, see setup.nls
  determine-EducationLevel                                                                                          ;; in this procedure, the EducationLevelal level of the households is determined, see setup.nls
  determine-HouseholdSize                                                                                           ;; in this procedure, the amount of persons in an household is determined, see setup.nls
  determine-Income                                                                                                  ;; in this procedure, the income of the households is determined, see setup.nls
  determine-RecyclingAwareness                                                                                      ;; in this procedure, the environmental RecyclingAwareness of the households is determined, see setup.nls
  determine-AvailableTime
  determine-AvailableSpace
  determine-ContainerRequiredTime                                                                                   ;; in this procedure, the required time to use a container for the households is determined, see setup.nls
  determine-CollectorRequiredTime                                                                                   ;; in this procedure, the required time to give recyclates to a collector for the households is determined, see setup.nls
  determine-CollectorRequiredSpace                                                                                  ;; in this procedure, the required space to store recyclates for a collector for the households is determined, see setup.nls
  determine-RecyclingKnowledge
  determine-WillingnessToChange
  

  
  ask allhouseholds [
    DetermineIntention
    UpdateIntentionColour
    CreateSocialNetwork
    InitialSociallyInteract
  ]
  

end

to Go
  SociallyInteract                                                                                                  ;; the procedure in which the households interact with eachother to deterimine social norm
  ProcessWaste                                                                                                      ;; the procedure in which the waste is generated, intention determined and waste processed
  DeterminePlotGlobals
  tick
  
  if MinimalTesting = true [
    if ticks = 1000 [
      stop
      ]
  ]
end

to SociallyInteract
  if ticks mod 7 = 1 [                                                                                               ;; The interaction is once every week
    Ask AllHouseholds [                                                                                                 
      let Recyclers 0
  
      foreach SocialNetwork [
        ask ? [
          if Intention > 0 [
            set Recyclers Recyclers + 1]
]
  ]
      
      set SocialNorm Recyclers / NetworkSize
    ]
  ]
  
end


to ProcessWaste
  ask AllHouseholds [
    set AmountOfWaste (                             ;; CHECK / VALIDATE !!!!
    AmountOfWaste + ( 0.5 + (( income - 40000 ) / 800000 + ( random 21 / 100 )) * householdsize ) / RecyclingAwareness )     ;; increases the waste with a constant of 0.5 + a factor between 0 and 0.2 related to income (40000 is 0, 200000 is 0.2) + a random factor between 0 and 0.2, then multiplies with householdsize and corrects for RecyclingAwareness
    if AmountOfWaste >= WasteTreshold [                                                                                        ;; decide whether the bins are full
      DetermineIntention                                                                                            ;; the procedure to decide the intention of households
      UpdateIntentionColour                                                                                         ;; the color of the patches has to be adjusted when the intention changes
      DecideBehaviour                                                                                               ;; the intention has to be transformed into the actual behaviour
      ActOnBehaviour    ]  ]                                                                                        ;; the procedure to actual get rid of the waste
end


to DetermineIntention                                                                                               ;; in this procedure the used theory detemines what decisiontree is used to come to a calculation of intention
  if TheoryOfBehaviour = "TRA"   [ DecisionTreeTRA ]
  if TheoryOfBehaviour = "TPB"   [ DecisionTreeTPB ]
  if TheoryOfBehaviour = "TPB+"  [ DecisionTreeTPB+ ]
end

 to DecisionTreeTRA
  if AvailabilityRecyclingMethods = "Both" [ ChoiceTRABoth ]                                                        ;; Fires if both the container and the collector methods are available                                                                                               ;; Decision Tree for TRA
  if AvailabilityRecyclingMethods = "Container" [ IntentionTRAContainer ]                                           ;; Fires if only the container based method is available
  if AvailabilityRecyclingMethods = "Collector" [ IntentionTRACollector ]                                           ;; Fires if only the collector based method is available
 end

 to ChoiceTRABoth                                                                                                   ;; Intention for TRA behavioural theory and container & collector methods
 let UtilityContainer ContainerIncentives - ( income / 40 * 52 * 60 ) * ContainerRequiredTime                       ;; The utility of the Container Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
 let UtilityCollector CollectorIncentives - ( income / 40 * 52 * 60 ) * CollectorRequiredTime                       ;; The utility of the Collector Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
 Ifelse UtilityContainer > UtilityCollector [ IntentionTRAContainer ] [ IntentionTRACollector ]                     ;; The method with the largest utility is chosen for intention calculation
 end

 to IntentionTRAContainer
  Ifelse ContainerIncentives / ( income / 1000 ) > 1                                                                ;; Check if containerinventives are more than 1% of the income
    [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
      let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit
    [ let PerceivedEconomicProfit ContainerIncentives / ( income / 1000 )                                           ;; If not bigger, incentives divided by a percent of the income determines the factor
      let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm ) / (WeightOfAttitude + WeightOfSocialNorm) > 0.5   ;; Checks if the average of the factors is above 0.5
  [ set Intention 1 ]                                                                                               ;; If yes, Containers will be used
  [ set Intention 0 ]                                                                                               ;; If no, LandFill will be used
 end

 to IntentionTRACollector                                                                                           ;; Intention for TRA behavioural theory and collector method
  Ifelse CollectorIncentives / ( income / 1000 ) > 1                                                                ;; Check if CollectorIncentives are more than 1% of the income
    [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit
    [ let PerceivedEconomicProfit CollectorIncentives / ( income / 1000 )                                           ;; If not bigger, incentives divided by a percent of the income determines the factor
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm ) / (WeightOfAttitude + WeightOfSocialNorm) > 0.5   ;; Checks if the average of the factors is above 0.5
  [ set Intention 2 ]                                                                                               ;; If yes, Collector will be used
  [ set Intention 0 ]                                                                                               ;; If no, LandFill will be used
 end


 to DecisionTreeTPB                                                                                                 ;; Decision Tree for TPB
  ifelse AvailabilityRecyclingMethods = "Both"      [ ChoiceTPBBoth ]                                               ;; Fires if both the container and the collector methods are available
    [ifelse AvailabilityRecyclingMethods = "Container" [ 
        IntentionTPBContainer ]                                                                                     ;; Fires if only the container based method is available
      [ IntentionTPBCollector ]   ]                                                                                 ;; Fires if only the collector based method is available
 end

 to ChoiceTPBBoth                                                                                                   ;; Intention for TPB behavioural theory and container & collector methods
  let UtilityContainer (ContainerIncentives - ( income / (MinutesPerHour * HoursPerWeek * WeeksPerYear) ) * ContainerRequiredTime)    ;; The utility of the Container Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
  let UtilityCollector (CollectorIncentives - ( income / (MinutesPerHour * HoursPerWeek * WeeksPerYear) ) * CollectorRequiredTime)    ;; The utility of the Collector Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
  Ifelse UtilityContainer > UtilityCollector [ IntentionTPBContainer ] [ IntentionTPBCollector ]                    ;; The method with the largest utility is chosen for intention calculation
 end

 to IntentionTPBContainer                                                                                           ;; Intention for TPB behavioural theory and container method
 Ifelse ContainerIncentives / ( income / 1000 ) > 1                                                                 ;; Check if containerinventives are more than 1% of the income
    [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
      let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit
    [ let PerceivedEconomicProfit ContainerIncentives / ( income / 1000 )                                           ;; If not bigger, incentives divided by a percent of the income determines the factor
      let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                                 ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                            ;; Attitude is formed by the average of awareness, Convenience and profit

  set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2                                  ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm + WeightOfPerceivedBehaviouralControl * PerceivedBehaviouralControl) / (WeightOfAttitude + WeightOfSocialNorm + WeightOfPerceivedBehaviouralControl) > 0.5   ;; Checks if the average of the factors is above 0.5
  [ set Intention 1 ]                                                                                               ;; If yes, Containers will be used
  [ set Intention 0 ]                                                                                               ;; If no, LandFill will be used
 end

 to IntentionTPBCollector                                                                                           ;; Intention for TPB behavioural theory and collector method
  Ifelse CollectorIncentives / ( income / 1000 ) > 1                                                                 ;; Check if CollectorIncentives are more than 1% of the income
    [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit
    [ let PerceivedEconomicProfit CollectorIncentives / ( income / 1000 )                                            ;; If not bigger, incentives divided by a percent of the income determines the factor
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit

  set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2                                  ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm + WeightOfPerceivedBehaviouralControl * PerceivedBehaviouralControl) / (WeightOfAttitude + WeightOfSocialNorm + WeightOfPerceivedBehaviouralControl) > 0.5   ;; Checks if the average of the factors is above 0.5
  [ set Intention 2 ]                                                                                               ;; If yes, Collector will be used
  [ set Intention 0 ]                                                                                               ;; If no, LandFill will be used
 end

 to DecisionTreeTPB+                                                                                                ;; Decision Tree for TPB+
  if AvailabilityRecyclingMethods = "Both"      [ ChoiceTPB+Both ]                                                  ;; Fires if both the container and the collector methods are available
  if AvailabilityRecyclingMethods = "Container" [ IntentionTPB+Container ]                                          ;; Fires if only the container based method is available
  if AvailabilityRecyclingMethods = "Collector" [ IntentionTPB+Collector ]                                          ;; Fires if only the collector based method is available
 end

 to ChoiceTPB+Both                                                                                                  ;; Intention for TPB+ behavioural theory and container & collector methods
  ifelse CollectorRequiredSpace > AvailableSpace [ IntentionTPB+Container ]                                         ;; If there is not enough space for collectors, intention will be calculated for containers, if there is enough, the time will be checked
    [ ifelse ContainerRequiredTime > AvailableTime [ IntentionTPB+Collector ]                                       ;; If there is too much time required for containers, intention will be calculated for collector use, if there is enough, utility is checked
    [ let UtilityContainer ContainerIncentives - ( income / (MinutesPerHour * HoursPerWeek * WeeksPerYear) ) * ContainerRequiredTime     ;; The utility of the Container Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
      let UtilityCollector CollectorIncentives - ( income / (MinutesPerHour * HoursPerWeek * WeeksPerYear) ) * CollectorRequiredTime     ;; The utility of the Collector Method is calculated by the worth of using a method, described by subtracting the RequiredTime * average income per minute from the incentives given (incentives come from sliders)
      Ifelse UtilityContainer > UtilityCollector [ IntentionTPB+Container ] [ IntentionTPB+Collector ] ] ]          ;; The method with the largest utility is chosen for intention calculation
 end

 to IntentionTPB+Container                                                                                          ;; Intention for TPB+ behavioural theory and container method
    ifelse ContainerRequiredTime > AvailableTime 
      [ Set Intention 0 
        Ifelse ContainerIncentives / ( income / 1000 ) > 1                                                          ;; Check if containerinventives are more than 1% of the income
       [ let PerceivedEconomicProfit 1                                                                              ;; If yes, household wants to get the incentive very much
         let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                            ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                       ;; Attitude is formed by the average of awareness, Convenience and profit
       [ let PerceivedEconomicProfit ContainerIncentives / ( income / 1000 )                                        ;; If not bigger, incentives divided by a percent of the income determines the factor
         let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                            ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                       ;; Attitude is formed by the average of awareness, Convenience and profit

         set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2   ]                        ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge]    
      
      [ Ifelse ContainerIncentives / ( income / 1000 ) > 1                                                          ;; Check if containerinventives are more than 1% of the income
       [ let PerceivedEconomicProfit 1                                                                              ;; If yes, household wants to get the incentive very much
         let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                            ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                       ;; Attitude is formed by the average of awareness, Convenience and profit
       [ let PerceivedEconomicProfit ContainerIncentives / ( income / 1000 )                                        ;; If not bigger, incentives divided by a percent of the income determines the factor
         let Convenience 1 - ( ContainerRequiredTime / AvailableTime )                                            ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                       ;; Attitude is formed by the average of awareness, Convenience and profit

         set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2                           ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm + WeightOfPerceivedBehaviouralControl * PerceivedBehaviouralControl) / (WeightOfAttitude + WeightOfSocialNorm + WeightOfPerceivedBehaviouralControl) > 0.5   ;; Checks if the average of the factors is above 0.5
    [ set Intention 1 ]                                                                                             ;; If yes, Containers will be used
    [ set Intention 0 ]   ]                                                                                         ;; If no, LandFill will be used
 end

 to IntentionTPB+Collector                                                                                          ;; Intention for TPB+ behavioural theory and collector method
    ifelse CollectorRequiredSpace > AvailableSpace  
      [ Set Intention 0                                                                                             ;; If there is too much space required for collector use, the waste will be put in the landfill (intention 0)
        Ifelse CollectorIncentives / ( income / 1000 ) > 1                                                                ;; Check if CollectorIncentives are more than 1% of the income
        [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
          let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit
        [ let PerceivedEconomicProfit CollectorIncentives / ( income / 1000 )                                           ;; If not bigger, incentives divided by a percent of the income determines the factor
          let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
          set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit
        set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2                                  ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge        
      ]
      [ 
  Ifelse CollectorIncentives / ( income / 1000 ) > 1                                                                ;; Check if CollectorIncentives are more than 1% of the income
    [ let PerceivedEconomicProfit 1                                                                                 ;; If yes, household wants to get the incentive very much
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit
    [ let PerceivedEconomicProfit CollectorIncentives / ( income / 1000 )                                           ;; If not bigger, incentives divided by a percent of the income determines the factor
      let Convenience 1 - ( CollectorRequiredTime / AvailableTime )                                               ;; Convenience starts at 1 and is reduced by the required time divided by the Available Time
       set Attitude ( RecyclingAwareness + PerceivedEconomicProfit + Convenience ) / 3 ]                          ;; Attitude is formed by the average of awareness, Convenience and profit

  set PerceivedBehaviouralControl ( WillingnessToChange + RecyclingKnowledge ) / 2                                  ;; PerceivedBehaviouralControl is formed by the average of Willingness to change and recycling knowledge

 Ifelse ( WeightOfAttitude * Attitude + WeightOfSocialNorm * SocialNorm + WeightOfPerceivedBehaviouralControl * PerceivedBehaviouralControl) / (WeightOfAttitude + WeightOfSocialNorm + WeightOfPerceivedBehaviouralControl) > 0.5   ;; Checks if the average of the factors is above 0.5
  [ set Intention 2 ]                                                                                               ;; If yes, Collector will be used
  [ set Intention 0 ]                                                                                               ;; If no, LandFill will be used
      ]
 end


to UpdateIntentionColour                 
  ifelse Intention = 1                                                                                              ;; if recycling intention is recycling,
    [ set pcolor Container-color ]                                                                                  ;; then the color of the household should be of Container use
    [ ifelse Intention = 2                                                                                          ;; if recycling intention is waiting for collector
       [ set pcolor Collector-color ]                                                                               ;; then the color of the household should be of waiting for collector
       [ set pcolor Landfill-color ] ]                                                                              ;; Else the color of the household should be of landfill
end


to DecideBehaviour                      ;; CHECK FIRST SCENTENCE IN VALIDATION !!!
  ifelse random 100 < TransformationIntoBehaviour                                                                   ;; 70% chance that the intention is tranformed into the desired behaviour
    [ set RecyclingBehaviour Intention ]                                                                            ;; in this line, the intention = behaviour
    [ ifelse Intention > 0                                                                                          ;; if intention is not landfill
        [ set RecyclingBehaviour Intention + 1]                                                                     ;; the behaviour equals intention + 1, they want to recycle but end up waiting for the collector or collector ends up to landfill
        [ set RecyclingBehaviour 3]  ]                                                                              ;; if intention is landfill, it is going to be landfill, because it can not be decreased more
end


to ActOnBehaviour                     
  ifelse RecyclingBehaviour = 1                                                                                     ;; when households actually recycle
    [ UseContainers ]                                                                                               ;; they get rid of their waste here
    [ ifelse RecyclingBehaviour = 2                                                                                 ;; when households wait for collectors at the door
      [ WaitForCollectors ]                                                                                         ;; they get rid of their waste with this procedure
      [ BringToLandfill ] ]                                                                                         ;; when households don't want to recycle, they get rid of their waste with this procedure
end


to UseContainers                                                                                                    ;; the procedure of getting rid of the waste by recycling, with the consequences of this behaviour
  set BroughtToContainer BroughtToContainer + AmountOfWaste
  set AmountOfWaste 0
end

to WaitForCollectors                                                                                                ;; the procedure of getting rid of the waste by waiting for collectors, with the consequences of this behaviour
  set CollectedRecyclates CollectedRecyclates + AmountOfWaste
  set AmountOfWaste 0
end

to BringToLandfill                                                                                                  ;; the procedure of getting rid of the waste by landfill, with the consequences of this behaviour
  set LandfillWaste LandfillWaste + AmountOfWaste
  set AmountOfWaste 0
end

to DeterminePlotGlobals
  set ParticipationRateContainer (count patches with [Intention = 1]) / count allhouseholds
  set ParticipationRateCollector (count patches with [Intention = 2]) / count allhouseholds
  set ParticipationRateLandfill (count patches with [Intention = 0 and pcolor != PhysicalContainer-color and pcolor != border-color]) / count allhouseholds 
end
@#$#@#$#@
GRAPHICS-WINDOW
336
12
1105
802
50
50
7.515
1
20
1
1
1
0
0
0
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
6
10
109
58
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
116
10
213
57
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

PLOT
1100
12
1588
365
Total waste
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Container" 1.0 0 -8732573 true "" "plot sum [BroughtToContainer] of patches"
"Collector" 1.0 0 -12087248 true "" "plot sum [CollectedRecyclates] of patches"
"Landfill" 1.0 0 -2674135 true "" "plot sum [LandfillWaste] of patches"

PLOT
1100
378
1590
782
participation rate
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Container" 1.0 0 -8732573 true "" "plot ParticipationRateContainer"
"Collector" 1.0 0 -12087248 true "" "plot ParticipationRateCollector"
"Landfill" 1.0 0 -2674135 true "" "plot ParticipationRateLandfill"

BUTTON
219
11
323
57
Go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
7
69
145
114
TheoryOfBehaviour
TheoryOfBehaviour
"TRA" "TPB" "TPB+"
2

CHOOSER
7
125
189
170
AvailabilityRecyclingMethods
AvailabilityRecyclingMethods
"Container" "Collector" "Both"
2

SLIDER
7
204
265
237
ContainerIncentives
ContainerIncentives
0
30
30
1
1
NIL
HORIZONTAL

SLIDER
8
247
266
280
CollectorIncentives
CollectorIncentives
0
30
30
1
1
NIL
HORIZONTAL

TEXTBOX
12
184
162
202
Policy Measures
11
0.0
1

SLIDER
9
363
267
396
TransformationIntoBehaviour
TransformationIntoBehaviour
50
100
100
1
1
NIL
HORIZONTAL

TEXTBOX
15
341
165
359
Constants
11
0.0
1

SLIDER
9
428
268
461
WeightOfAttitude
WeightOfAttitude
0
5
1
1
1
NIL
HORIZONTAL

SLIDER
9
509
267
542
WeightOfPerceivedBehaviouralControl
WeightOfPerceivedBehaviouralControl
0
5
1
1
1
NIL
HORIZONTAL

SLIDER
9
468
268
501
WeightOfSocialNorm
WeightOfSocialNorm
0
5
1
1
1
NIL
HORIZONTAL

TEXTBOX
12
407
162
425
Weight of theory components
11
0.0
1

SWITCH
25
861
160
894
MinimalTesting
MinimalTesting
1
1
-1000

MONITOR
1603
69
1818
114
Total waste brought to containers
sum [BroughtToContainer] of patches
17
1
11

MONITOR
1604
124
1819
169
Total collected waste
sum [CollectedRecyclates] of patches
17
1
11

MONITOR
1604
180
1819
225
Total landfill waste
sum [LandfillWaste] of patches
17
1
11

MONITOR
1604
238
1819
283
Average attitude
mean [Attitude] of Allhouseholds
17
1
11

MONITOR
1604
297
1820
342
Average Social Norm
mean [SocialNorm] of Allhouseholds
17
1
11

MONITOR
1604
353
1821
398
Average Perceived Behavioural Control
mean [PerceivedBehaviouralControl] of Allhouseholds
17
1
11

MONITOR
1603
14
1817
59
Total Waste
sum [broughttocontainer] of patches + sum [collectedrecyclates] of patches + sum [landfillwaste] of patches
17
1
11

@#$#@#$#@
## WHAT IS IT?

THe model represents a village in the surroundings of Beijing, called Huangchao Fanbu Yaoliie. In this village runs an experiment about the recycling behaviour of its citizens. With collectors, containers and rewards the experiment tries to stimulate the civilians to recycle their valuable waste.
The village consists of three separate areas, namely the university area (west and northwest), the area that is mostly populated by locals (east and northeast) and the area with independent housing (southwest, south and southeast). In the area the experiment placed six containers where civilians could get rid of the waste.
The behaviour of the households is tested with three different social theories, namely the theory of reasoned action (TRA), the theory of planned behaviour (TPB) and the theory of planned behaviour extended with situational factors (TPB+). 

## HOW IT WORKS

This model has a few important procedures that influence the model greatly. These procedures are the waste generation, intention determination and social interaction. 
In the waste generation procedure, the households generate waste, based on their environmental awareness and income. When the household accumulates a certain amount of waste, it has to dispose of this waste.
The intention determination procedure determines whether a household is recycling and which recycling option it is going to use, based on the utility of the different recycling options. The intention is based on personal attitude and social norm (TRA), personal attitude, social norm and perceived behavioural control (TPB), or personal attitude, social norm, perceived behavioural control and situational factors (TPB+).
The procedure of social interaction is about determining the social norm. When many neighbours and other acquaintances recycle, the civilians will be more willing to recycle as well.

## HOW TO USE IT

In the interface, several sliders are available to influence the model, next to the monitors and plots to observe the output. On the left hand side the model parameters can be adjusted by using the choosers and sliders. The different behaviour theories and the availability of recycling methods can be chosen with the two choosers at the upper left corner. Under these choosers are the sliders of the economic incentives of the collector and container. These can be used to vary the incentives between 0 and 30. 
Under the economic sliders is the TransformationIntoBehaviour slider placed. This slider determines the chance that civilians actually do what they intend to do. The last three sliders are the weights of the attitude, social norm and perceived behavioural control. 

On the right hand side are two graphs, the graph of total waste, divided over the different disposal manners (in kg) and the intended participation rate of the different disposal manners (as a percentage of the entire population). Furthermore, there are seven monitors at the right hand side. These are the total waste, the total waste per disposal manner and the average attitude, social norm and perceived behavioural control of the households in the model.  

## THINGS TO NOTICE

Households start to recycle first in the university region. They are the higher educated civilians, with higher knowledge and awareness. Furthermore, the people start to recycle close to the containers. Being close to a container means a higher convenience and therefore a more positive attitude. 

## THINGS TO TRY

It is interesting to see what the influence of the weights of attitude, social norm and perceived behavioural control is. The relative importance is unknown in the real world, but very influential for the model output. 

## EXTENDING THE MODEL

Many assumptions are used in the model, due to the lack of real data. The relations between the different components of the social theory and their weights for example are unknown. Some of the personal properties are set up randomly, also because of the lack of data.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
