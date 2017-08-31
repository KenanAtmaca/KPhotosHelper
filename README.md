# KPhotosHelper
İOS Photos Framework Helper Class 🌄

### Usage

```Swift
     var photo = KPhotosHelper()
```

##### Fetch Images in Camera roll

```Swift
     photo.fetchImage(size: CGSize.init(width: 200, height: 200))
```

##### Fetch Image in Albums

```Swift
     photo.fetchImageWithAlbum(size: CGSize.init(width: 200, height: 200), album: "Summer")
```

##### Save Files (Photo,Video)

```Swift
    photo.saveImage(image: mImg, completion: nil)  
```

```Swift
    photo.saveImageInAlbum(image: mImg, album: "Summer", completion: nil)
```

```Swift
    photo.saveVideo(url: videoURL, completion: nil)
```

##### Delete Photo

```Swift
    photo.deletePhoto(asset: pAsset)
```

##### Create Album

```Swift
    photo.createAlbum(album: "XXX")
```

##### Auth

```Swift
    if photo.requestAuthStatus() {
            // code
        }
```

#### Use Cache

- [X] Basic CollectionView Fetch Example

```Swift
    var photo = KPhotosHelper()
   
    override func viewDidLoad() {
        super.viewDidLoad()
 
        photo.fetchImage(size: CGSize.init(width: 200, height: 200)) // #1 Fetch
       
        cView.delegate = self
        cView.dataSource = self
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.imagesAsset.count // #2 Cell Count After Fetch
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PCell
        
        let assets = photo.imagesAsset[indexPath.row] // #3 PHAsset Photos
        cell.cellImg.image = photo.loadCacheImage(asset: assets, size: CGSize(width: 200, height: 200)) // ##4 Load Cache

        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        return cell
    }
```


