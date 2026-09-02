import { Module } from '@nestjs/common';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { MessagesModule } from './modules/messages/messages.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { AiModule } from './modules/ai/ai.module';
import { PrivacyModule } from './modules/privacy/privacy.module';
import { BizModule } from './modules/biz/biz.module';

@Module({
  imports: [
    AuthModule,
    UsersModule,
    MessagesModule,
    DashboardModule,
    AiModule,
    PrivacyModule,
    BizModule,
  ],
})
export class AppModule {}
