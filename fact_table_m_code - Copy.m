let
    Source = Csv.Document(File.Contents("songs_normalize.csv"),[Delimiter=",", Columns=18, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"artist", type text}, {"song", type text}, {"duration_ms", Int64.Type}, {"explicit", type logical}, {"year", Int64.Type}, {"popularity", Int64.Type}, {"danceability", type number}, {"energy", type number}, {"key", Int64.Type}, {"loudness", type number}, {"mode", Int64.Type}, {"speechiness", type number}, {"acousticness", type number}, {"instrumentalness", type number}, {"liveness", type number}, {"valence", type number}, {"tempo", type number}, {"genre", type text}}),
    #"Removed Other Columns" = Table.SelectColumns(#"Changed Type",{"artist", "song", "duration_ms", "popularity", "key", "tempo", "genre"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Other Columns", "IsRock", each if Text.Contains([genre], "rock") then true else false),
    #"Filtered Rows" = Table.SelectRows(#"Added Conditional Column", each ([IsRock] = true)),
    #"Replaced Value" = Table.ReplaceValue(#"Filtered Rows","pop, rock","rock, pop",Replacer.ReplaceText,{"genre"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","Folk/Acoustic, rock, pop","rock, Folk/Acoustic, pop",Replacer.ReplaceText,{"genre"}),
    #"Replaced Value2" = Table.ReplaceValue(#"Replaced Value1","rock, pop, Folk/Acoustic","rock, Folk/Acoustic, pop",Replacer.ReplaceText,{"genre"}),
    #"Added Custom" = Table.AddColumn(#"Replaced Value2", "Duration (Seconds)", each Number.Round([duration_ms] / 1000)),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Custom", "Key Name", each if [key] = 0 then "C" else if [key] = 1 then "C#/Db" else if [key] = 2 then "D" else if [key] = 3 then "D#/Eb" else if [key] = 4 then "E" else if [key] = 5 then "F" else if [key] = 6 then "F#/Gb" else if [key] = 7 then "G" else if [key] = 8 then "G#/Ab" else if [key] = 9 then "A" else if [key] = 10 then "A#/Bb" else "B"),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Conditional Column1",{"artist", "song", "popularity", "key", "tempo", "genre", "Duration (Seconds)", "Key Name"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Other Columns1",{"artist", "song", "popularity", "key", "Key Name", "tempo", "genre", "Duration (Seconds)"}),
    #"Merged Queries" = Table.NestedJoin(#"Reordered Columns", {"genre"}, DimGenre, {"Genre Name"}, "DimGenre", JoinKind.LeftOuter),
    #"Expanded DimGenre" = Table.ExpandTableColumn(#"Merged Queries", "DimGenre", {"Genre ID"}, {"DimGenre.Genre ID"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded DimGenre",{{"DimGenre.Genre ID", "Genre ID"}}),
    #"Removed Other Columns2" = Table.SelectColumns(#"Renamed Columns",{"artist", "song", "popularity", "key", "tempo", "Duration (Seconds)", "Genre ID"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns2",{{"artist", "Artist"}, {"song", "Song Title"}, {"popularity", "Popularity"}, {"key", "Key Number"}, {"tempo", "Tempo"}})
in
    #"Renamed Columns1"