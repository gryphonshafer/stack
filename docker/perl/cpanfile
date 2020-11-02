feature 'cpan', 'cpan Modules' => sub {
    requires 'App::cpanminus';
    requires 'App::cpanoutdated';
    requires 'Module::Signature';
    requires 'Digest::SHA';
};

feature 'exact', 'exact Modules' => sub {
    requires 'exact';
    requires 'exact::class';
    requires 'exact::cli';
    requires 'exact::conf';
};

feature 'develop', 'Development Tools' => sub {
    requires 'Benchmark';
    requires 'Data::Printer';
    requires 'Perl::Critic';
    requires 'Perl::Tidy';
    requires 'Term::ReadKey';
    requires 'Term::ReadLine::Perl';
    requires 'Term::ANSIColor';
    requires 'Devel::NYTProf';
};

feature 'test', 'Testing Tools' => sub {
    requires 'Test::Most';

    requires 'Test::Class';
    requires 'Test::MockModule';

    requires 'WWW::Mechanize';
    requires 'Test::WWW::Mechanize';

    requires 'Test::CheckManifest';
    requires 'Test::EOL';
    requires 'Test::Kwalitee';
    requires 'Test::NoTabs';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
    requires 'Test::Synopsis';

    requires 'Devel::Cover::Report::Coveralls';
    requires 'Pod::Coverage::TrustPod';
};

feature 'cover', 'Coverage Analysis' => sub {
    requires 'Devel::Cover';
    requires 'Parallel::Iterator';
    requires 'Pod::Coverage';
    requires 'Pod::Coverage::CountParents';
    requires 'PPI::HTML';
    requires 'Template';
};

feature 'data', 'Data Access Channels' => sub {
    requires 'YAML::XS';
    requires 'JSON::XS';
    requires 'DBIx::Query';
};

feature 'files', 'File System Tools' => sub {
    requires 'File::Path';
    requires 'IO::All';
};

feature 'logging', 'Logging Tools' => sub {
    requires 'Log::Dispatch';
    requires 'Log::Dispatch::Email::Mailer';
};

feature 'datetime', 'Dates and Times' => sub {
    requires 'Date::Format';
    requires 'Date::Parse';
    requires 'DateTime';
    requires 'DateTime::Duration';
    requires 'DateTime::Format::Human::Duration';
};

feature 'moose', 'Moose Development' => sub {
    requires 'Moose';
    requires 'MooseX::MarkAsMethods';
    requires 'MooseX::NonMoose';
    requires 'MooseX::ClassAttribute';
    requires 'Throwable::Error';
    requires 'Test::Moose';
};

feature 'mojo', 'Mojolicious Development' => sub {
    requires 'Mojolicious';
    requires 'Mojolicious::Plugin::AccessLog';
    requires 'Mojolicious::Plugin::ToolkitRenderer';
    requires 'MojoX::Log::Dispatch::Simple';

    requires 'Mojolicious::Plugin::Directory';
    requires 'Text::MultiMarkdown';

    requires 'Template';
    requires 'Input::Validator';
};

feature 'html', 'HTML and URL Processing' => sub {
    requires 'HTML::TreeBuilder';
    requires 'HTML::FormatText';
    requires 'URI::Escape';
    requires 'Convert::Base32';
    requires 'HTML::TokeParser::Simple';
};

feature 'mail', 'Mail Utilities' => sub {
    requires 'Email::Mailer';
    requires 'Template';

    requires 'Mail::Sender';
    requires 'Net::IMAP::Simple';
    requires 'Email::Simple';
};

feature 'encryption', 'Encryption and Hashing' => sub {
    requires 'Crypt::CBC';
    requires 'Crypt::Blowfish';
    requires 'Digest::SHA1';
    requires 'Digest::MD5';
    requires 'Digest::HMAC_SHA1';
};

feature 'daemon', 'Daemon Build and Control' => sub {
    requires 'Daemon::Control';
    requires 'Daemon::Device';
};

feature 'cli', 'CLI Utilities' => sub {
    requires 'Config::App';
    requires 'Util::CommandLine';
    requires 'Time::DoAfter';
};

feature 'deploy', 'Deployment Tools' => sub {
    requires 'App::Dest';
    requires 'Sub::Versions';
};

feature 'reply', 'Reply REPL CLI Environment' => sub {
    requires 'Reply';
    requires 'Reply::Plugin::ConfigurablePrompt';
    requires 'Reply::Plugin::Pager';
    requires 'B::Keywords';
    requires 'Class::Refresh';
    requires 'Carp::Always';
    requires 'Proc::InvokeEditor';
    requires 'IO::Pager';
    requires 'Data::Printer';
    requires 'Term::ReadKey';
    requires 'Term::ReadLine::Perl';
};

feature 'dzil', 'Dist::Zilla and Plugins' => sub {
    requires 'Dist::Zilla';
    requires 'Dist::Zilla::Plugin::Clean';
    requires 'Dist::Zilla::Plugin::GithubMeta';
    requires 'Dist::Zilla::Plugin::MinimumPerl';
    requires 'Dist::Zilla::Plugin::OurPkgVersion';
    requires 'Dist::Zilla::Plugin::PodWeaver';
    requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';
    requires 'Dist::Zilla::Plugin::Run::AfterBuild';
    requires 'Dist::Zilla::Plugin::Test::Compile';
    requires 'Dist::Zilla::Plugin::Test::EOL';
    requires 'Dist::Zilla::Plugin::Test::Kwalitee';
    requires 'Dist::Zilla::Plugin::Test::NoTabs';
    requires 'Dist::Zilla::Plugin::Test::Portability';
    requires 'Dist::Zilla::Plugin::Test::Synopsis';
    requires 'Dist::Zilla::PluginBundle::Git';

    requires 'Archive::Tar::Wrapper';
    requires 'Pod::Elemental::Transformer::List';
};
