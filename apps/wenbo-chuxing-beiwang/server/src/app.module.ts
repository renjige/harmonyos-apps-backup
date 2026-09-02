import { Module } from '@nestjs/common';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { MessagesModule } from './modules/messages/messages.module';
import { PrivacyModule } from './modules/privacy/privacy.module';

@Module({
  imports: [
    AuthModule,
    UsersModule,
    MessagesModule,
    PrivacyModule,
  ],
})
export class AppModule {}
