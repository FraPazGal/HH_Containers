<?php

/**
 * @link https://www.humhub.org/
 * @copyright Copyright (c) 2017 HumHub GmbH & Co. KG
 * @license https://www.humhub.com/licences
 */

namespace humhub\commands;

use Yii;
use yii\console\Controller;
use yii\console\ExitCode;
use yii\helpers\Console;
use yii\base\Exception;
use humhub\modules\user\models\User;
use humhub\modules\user\models\Password;
use humhub\modules\user\models\Group;
use humhub\modules\installer\libs\InitialData;
use humhub\modules\queue\driver\Sync;
use humhub\modules\space\models\Space;
use humhub\libs\UUID;
use humhub\libs\DynamicConfig;

/**
 * Console Install
 * 
 * Example usage:
 *   php yii installer/write-db-config "$HUMHUB_DB_HOST" "$HUMHUB_DB_NAME" "$HUMHUB_DB_USER" "$HUMHUB_DB_PASSWORD"
 *   php yii installer/install-db
 *   php yii installer/write-site-config "$HUMHUB_NAME" "$HUMHUB_EMAIL"
 *   php yii installer/create-admin-account
 * 
 */
class InstallController extends Controller
{
    /**
     * Finished install without input. Useful for testing.
     */
    public function actionAuto()
    {
        $this->actionWriteSiteConfig();
        $this->actionCreateAdminAccount();

        return ExitCode::OK;
    }
    
    /**
     * Tries to open a connection to given db. 
     * On success: Writes given settings to config-file and reloads it.
     * On failure: Throws exception
     */
    public function actionWriteDbConfig($db_host, $db_name, $db_user, $db_pass) {
        $connectionString = "mysql:host=" . $db_host . ";dbname=" . $db_name;
        $dbConfig = [
            'class' => 'yii\db\Connection',
            'dsn' => $connectionString,
            'username' => $db_user,
            'password' => $db_pass,
            'charset' => 'utf8',
        ];

        $temporaryConnection = Yii::createObject($dbConfig);
        $temporaryConnection->open();

        $config = DynamicConfig::load();

        $config['components']['db'] = $dbConfig;
        $config['params']['installer']['db']['installer_hostname'] = $db_host;
        $config['params']['installer']['db']['installer_database'] = $db_name;

        DynamicConfig::save($config);

        return ExitCode::OK;
    }

    /**
     * Checks configured db, flushes caches, runs migrations and sets installed state in config
     */
    public function actionInstallDb()
    {
        $this->stdout("Install DB:\n\n", Console::FG_YELLOW);

        $this->stdout("  * Checking Database Connection\n", Console::FG_YELLOW);
        if(!$this->checkDBConnection()){
            throw new Exception("Could not connect to DB!");
        }

        $this->stdout("  * Installing Database\n", Console::FG_YELLOW);
        
        Yii::$app->cache->flush();
        // Disable max execution time to avoid timeouts during migrations
        @ini_set('max_execution_time', 0);
        \humhub\commands\MigrateController::webMigrateAll();

        DynamicConfig::rewrite();

        $this->setDatabaseInstalled();

        $this->stdout("  * Finishing\n", Console::FG_YELLOW);
        $this->setInstalled();

        return ExitCode::OK;
    }

    /**
     * Creates a new user account and adds it to the admin-group
     */
    public function actionCreateAdminAccount($admin_user='admin', $admin_email='humhub@example.com', $admin_pass='test', $admin_firstname='Sys', $admin_lastname='Admin', $sample_data=true)
    {
        $user = new User();
        $user->username = $admin_user;
        $user->email = $admin_email;
        $user->status = User::STATUS_ENABLED;
        $user->language = '';
        if (!$user->save()) {
            throw new Exception("Could not save user");
        }

        $user->profile->title = 'System Administrator';
        $user->profile->firstname = $admin_firstname;
        $user->profile->lastname = $admin_lastname;
        $user->profile->save();

        $password = new Password();
        $password->user_id = $user->id;
        $password->setPassword($admin_pass);
        $password->save();

        Group::getAdminGroup()->addUser($user);

	if(preg_match("/yes|y|Yes|YES/", $sample_data)) {

            $form = new \humhub\modules\installer\forms\SampleDataForm();
    
            $form->sampleData = 1;
            if ($form->validate()) {
                Yii::$app->getModule('installer')->settings->set('sampleData', $form->sampleData);
    
                if (Yii::$app->getModule('installer')->settings->get('sampleData') == 1) {
    
                    // Add sample image to admin
                    $admin = User::find()->where(['id' => 1])->one();
                    $adminImage = new \humhub\libs\ProfileImage($admin->guid);
                    $adminImage->setNew(Yii::getAlias("@webroot-static/resources/installer/user_male_1.jpg"));
                    $usersGroup = Group::findOne(['name' => 'Users']);
    
                    // Create second user
                    $userModel = new User();
                    $userModel->scenario = 'registration';
                    $userModel->status = User::STATUS_ENABLED;
                    $userModel->username = "david1986";
                    $userModel->email = "david.roberts@example.com";
                    $userModel->language = '';
                    $userModel->tags = "Microsoft Office, Marketing, SEM, Digital Native";
                    $userModel->save();
    
                    $profileImage = new \humhub\libs\ProfileImage($userModel->guid);
                    $profileImage->setNew(Yii::getAlias("@webroot-static/resources/installer/user_male_2.jpg"));

                    $userModel->profile->user_id = $userModel->id;
                    $userModel->profile->firstname = "David";
                    $userModel->profile->lastname = "Roberts";
                    $userModel->profile->title = "Late riser";
                    $userModel->profile->scenario = 'registration';
                    $userModel->profile->street = "2443 Queens Lane";
                    $userModel->profile->zip = "24574";
                    $userModel->profile->city = "Allwood";
                    $userModel->profile->country = "Virginia";
                    $userModel->profile->save();

                    if ($usersGroup !== null) {
                        $usersGroup->addUser($userModel);
                    }
    
                    // Create third user
                    $userModel2 = new User();
                    $userModel2->scenario = 'registration';
                    $userModel2->profile->scenario = 'registration';
    
                    $userModel2->status = User::STATUS_ENABLED;
                    $userModel2->username = "sara1989";
                    $userModel2->email = "sara.schuster@example.com";
                    $userModel2->language = '';
                    $userModel2->tags = "Yoga, Travel, English, German, French";
                    $userModel2->save();

                    $profileImage2 = new \humhub\libs\ProfileImage($userModel2->guid);
                    $profileImage2->setNew(Yii::getAlias("@webroot-static/resources/installer/user_female_1.jpg"));
    
                    $userModel2->profile->user_id = $userModel2->id;
                    $userModel2->profile->firstname = "Sara";
                    $userModel2->profile->lastname = "Schuster";
                    $userModel2->profile->title = "Do-gooder";
                    $userModel2->profile->street = "Schmarjestrasse 51";
                    $userModel2->profile->zip = "17095";
                    $userModel2->profile->city = "Friedland";
                    $userModel2->profile->country = "Niedersachsen";
                    $userModel2->profile->save();
    
                    if ($usersGroup !== null) {
                        $usersGroup->addUser($userModel2);
                    }
    
                    // Switch to Sync queue while setting up example contents
                    // This is required to avoid sending e-mail notifications for sample data
                    try {
                        Yii::$app->set('queue', new Sync());
                    } catch (InvalidConfigException $e) {
                        Yii::error('Could not switch queue: ' . $e->getMessage());
                    }

                    // Switch Identity
                    $user = User::find()->where(['id' => 1])->one();
                    Yii::$app->user->switchIdentity($user);
    
                    $space = new Space();
                    $space->name = 'Test Space';
                    $space->status = Space::VISIBILITY_ALL;
                    $space->save();
    
                    // Create a sample post
                    $post = new \humhub\modules\post\models\Post();
                    $post->message = Yii::t("InstallerModule.base", "We're looking for great slogans of famous brands. Maybe you can come up with some samples?");
                    $post->content->container = $space;
                    $post->content->visibility = \humhub\modules\content\models\Content::VISIBILITY_PUBLIC;
                    $post->save();
    
                    // Switch Identity
                    Yii::$app->user->switchIdentity($userModel);
    
                    $comment = new \humhub\modules\comment\models\Comment();
                    $comment->message = Yii::t("InstallerModule.base", "Nike  ^`^s Just buy it. ;Wink;");
                    $comment->object_model = $post->className();
                    $comment->object_id = $post->getPrimaryKey();
                    $comment->save();

                    // Switch Identity
                    Yii::$app->user->switchIdentity($userModel2);
    
                    $comment2 = new \humhub\modules\comment\models\Comment();
                    $comment2->message = Yii::t("InstallerModule.base", "Calvin Klein  ^`^s Between love and madness lies obsession.");
                    $comment2->object_model = $post->className();
                    $comment2->object_id = $post->getPrimaryKey();
                    $comment2->save();
    
                    // Create Like Object
                    $like = new \humhub\modules\like\models\Like();
                    $like->object_model = $comment->className();
                    $like->object_id = $comment->getPrimaryKey();
                    $like->save();
    
                    $like = new \humhub\modules\like\models\Like();
                    $like->object_model = $post->className();
                    $like->object_id = $post->getPrimaryKey();
                    $like->save();
                }
            }
        }

        return ExitCode::OK;
    }

    /**
     * Writes essential site settings to config file and sets installed state
     */
    public function actionWriteSiteConfig($site_name='HumHub', $site_email='humhub@example.com',$allow_guest_access=true, $require_internal_approval_after_registration=true, $allow_anon_registration=false, $invite_by_email=true, $enable_friends_module=false){
        $this->stdout("Install Site:\n\n", Console::FG_YELLOW);

	InitialData::bootstrap();

        Yii::$app->settings->set('name', $site_name);
        Yii::$app->settings->set('mailer.systemEmailName', $site_email);
        Yii::$app->settings->set('secret', UUID::v4());
        Yii::$app->settings->set('timeZone', Yii::$app->timeZone);

        $form = new \humhub\modules\installer\forms\SecurityForm();

        $form->allowGuestAccess = preg_match("/yes|y|Yes|YES/", $allow_guest_access);
        $form->internalRequireApprovalAfterRegistration = preg_match("/yes|y|Yes|YES/", $require_internal_approval_after_registration);
        $form->internalAllowAnonymousRegistration = preg_match("/yes|y|Yes|YES/", $allow_anon_registration);
        $form->canInviteExternalUsersByEmail = preg_match("/yes|y|Yes|YES/", $invite_by_email);
        $form->enableFriendshipModule = preg_match("/yes|y|Yes|YES/", $enable_friends_module);

        if ($form->validate()) {
            Yii::$app->getModule('user')->settings->set('auth.needApproval', $form->internalRequireApprovalAfterRegistration);
            Yii::$app->getModule('user')->settings->set('auth.anonymousRegistration', $form->internalAllowAnonymousRegistration);
            Yii::$app->getModule('user')->settings->set('auth.allowGuestAccess', $form->allowGuestAccess);
            Yii::$app->getModule('user')->settings->set('auth.internalUsersCanInvite', $form->canInviteExternalUsersByEmail);
            Yii::$app->getModule('friendship')->settings->set('enable', $form->enableFriendshipModule);
        }

        $this->setInstalled();

        return ExitCode::OK;
    }

    /**
     * Sets the base url
     */
    public function actionSetBaseUrl($base_url){
        $this->stdout("Setting base url", Console::FG_YELLOW);
        Yii::$app->settings->set('baseUrl', $base_url);

        return ExitCode::OK;
    }

     /**
     * Sets application in installed state (disables installer)
     */
    private function setInstalled()
    {
        $config = DynamicConfig::load();
        $config['params']['installed'] = true;
        DynamicConfig::save($config);
    }

    /**
     * Sets application database in installed state
     */
    private function setDatabaseInstalled()
    {
        $config = DynamicConfig::load();
        $config['params']['databaseInstalled'] = true;
        DynamicConfig::save($config);
    }

    /**
     * Tries to open global db connection and checks result.
     */
    private function checkDBConnection()
    {
        try {
            // call setActive with true to open connection.
            Yii::$app->db->open();
            // return the current connection state.
            return Yii::$app->db->getIsActive();
        } catch (Exception $e) {
            $this->stderr($e->getMessage());
        }
        return false;
    }
}
