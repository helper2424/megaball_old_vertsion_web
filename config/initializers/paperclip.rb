Paperclip::Attachment.default_options.update({

  path: ':rails_root/public:url',

  fog_directory: 'Megaball',
  fog_public: true,
  fog_host: 'https://asset.r3studio.ru',
  
  fog_credentials: {
    provider: 'Rackspace',
    rackspace_username: '26697',
    rackspace_api_key: 'c0kx333M',
    rackspace_auth_url: 'https://auth.selcdn.ru/'
  }
})
