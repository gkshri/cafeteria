# README #


## Note ##

This version might not be compaitable with all browsers to use full functionality test on google chrome

---

* run before testing locally 
```
bundle install --without production
```

* create data base and add admin to users 
```
rake db:create
rake db:migrate
rake db:seed
```

* to upload images to use it @ paperclip gem
```
sudo yum install imagemagick
sudo apt-get install imagemagick -y
```

* to login open in browser
* localhost:3000/login
* admin email : 'admin@cafeteria'
* admin password : 'admin'
