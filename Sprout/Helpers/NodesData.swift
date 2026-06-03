

import FoundationModels


@Generable
struct NodesData {


    // Actionable items extracted from the note (may be empty)
    @Guide(description: "extremely spesific Actionalbe items in a road mape like format, extracted from the note assuming the user is a beginner. dont make it too broad, but make it so spesific that the user can immedietly take action by just reading the item. the item should be a daily task to do instead of a long term goals. the items should not be everyday practice but spesific to that day. the item should be a roadmap for a complete beginner to get to know some the stuff they want to do. , some day the item could just be a practice and some day it could be about learning", .count(5))
    let actionItems: [String]

    
}

