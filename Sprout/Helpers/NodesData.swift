

import FoundationModels


@Generable
struct NodesData {


    // Actionable items extracted from the note (may be empty)
    @Guide(description: "Create extremely spesific Actionalbe items in a road mape like format, using contextextracted from the note. Assume the user is a total beginner. Make the items very spesific actionable item like for 'learning to play guitar' the nodes could be 'Practice C, D and G strings' or 'Practice with Kiss Me by The Beatles Song', or if they are learning how to cook 'cook an omlette', 'cook a scrambled egg', ''cook a roast beef sandwich. not something broa like 'cook a meal'. The items should be in a way that they can be broken down into smaller steps. Make it so spesific that the user can immedietly take action by just reading the item. the item should be a daily task to do instead of a long term goals. the items should not be general stuff. the item should be a roadmap for a complete beginner to get to know somemof the stuff they want to do. some day the item could just be a practice and some day it could be about learning. important to note that some of the title have 'I' behind them each 'I' represents that they have done 20 task of related title. so you can make the goals that are new and a bit harder than the ones that are done. ", .count(5))
    let actionItems: [String]

    
}

