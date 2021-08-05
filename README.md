Repository of Mehmet Caliskan

Commit and push test

if self.isFiltering {
    if let safeId = self.filteredMovies[indexPath.row].id {
        if let index = self.favoriteMovies.firstIndex(of: "chimps") {
            animals.remove(at: index)
        }
        self.favoriteMovies.rem(safeId)
    } else {
        print("Error during ID fetching")
    }
} else {
    if let safeId = self.movies[indexPath.row].id {
        self.favoriteMovies.append(safeId)
    } else {
        print("Error during ID fetching")
    }
}
