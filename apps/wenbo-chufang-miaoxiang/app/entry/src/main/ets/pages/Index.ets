import { Theme } from '../components/design-system/Theme'
import { MainTabPage } from './MainTabPage'

enum AppStage {
  Splash = 0,
  Main = 1
}

@Entry
@Component
struct Index {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stage: AppStage = AppStage.Splash
  @StorageLink('companyName') company: string = '魏文波'
  @StorageLink('appDisplayName') appName: string = '厨房妙想'
  @StorageLink('appTagline') tagline: string = '发现简单好吃的厨房灵感，让每天做饭变得更轻松'

  aboutToAppear(): void {
    setTimeout(() => {
      this.stage = AppStage.Main
    }, 680)
  }

  build() {
    Stack() {
      if (this.stage === AppStage.Splash) {
        Column({ space: Theme.space.s4 }) {
          Image($r('app.media.app_icon'))
            .width(96)
            .height(96)
            .borderRadius(28)
          Text('厨房妙想')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('今天，厨房有什么新想法？')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else {
        Column() {
          MainTabPage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenLogin: () => {},
            onLogout: () => {},
            onRequireAuth: () => {}
          })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
