import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextField } from '../design-system/AppTextField'
import { DetailShell } from '../detail/DetailShell'
import { PracticeItem, PracticeKind } from '../../models/PracticeModels'
import { AtelierPractice } from '../../services/AtelierPractice'
import { AtelierDetailNav } from '../../services/AtelierDetailNav'
import { AtelierTime } from '../../models/AtelierModels'

@Component
export struct PracticeSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'review'
  @Prop editId: string = ''
  @State workKind: string = 'review'
  @State title: string = ''
  @State fieldA: string = ''
  @State fieldB: string = ''
  @State fieldC: string = ''
  @State cal: boolean = true
  @State phone: boolean = true
  @State im: boolean = true
  @State logistics: boolean = false
  @State news: boolean = false
  @State social: boolean = false
  @State walkSec: number = 0
  @State walking: boolean = false
  @State confirmDel: boolean = false
  private tickId: number = -1
  private itemId: string = ''

  aboutToAppear(): void {
    this.workKind = this.kind.length > 0 ? this.kind : 'review'
    this.title = new PracticeItem().kindLabel()
    if (this.editId.length > 0) {
      const found = AtelierPractice.find(this.editId)
      if (found !== undefined) {
        this.itemId = found.id
        this.workKind = found.kind
        this.title = found.title
        this.fieldA = found.fieldA
        this.fieldB = found.fieldB
        this.fieldC = found.fieldC
        this.applyWhitelist(found.fieldA)
      }
    } else {
      const blank = PracticeItem.of('', this.workKind, '', '', '', '', '', 0, '')
      this.title = blank.kindLabel()
    }
  }

  aboutToDisappear(): void {
    this.clearTick()
  }

  private clearTick(): void {
    if (this.tickId >= 0) {
      clearInterval(this.tickId)
      this.tickId = -1
    }
  }

  private applyWhitelist(raw: string): void {
    this.cal = raw.indexOf('日历') >= 0
    this.phone = raw.indexOf('电话') >= 0
    this.im = raw.indexOf('即时通讯') >= 0
    this.logistics = raw.indexOf('物流') >= 0
    this.news = raw.indexOf('资讯') >= 0
    this.social = raw.indexOf('社交') >= 0
  }

  private whitelistText(): string {
    let out = ''
    if (this.cal) {
      out += '日历,'
    }
    if (this.phone) {
      out += '电话,'
    }
    if (this.im) {
      out += '即时通讯,'
    }
    if (this.logistics) {
      out += '物流,'
    }
    if (this.news) {
      out += '资讯,'
    }
    if (this.social) {
      out += '社交,'
    }
    return out
  }

  private startWalk(): void {
    this.walking = true
    this.clearTick()
    this.tickId = setInterval((): void => { this.walkSec = this.walkSec + 1 }, 1000)
  }

  private stopWalk(): void {
    this.walking = false
    this.clearTick()
  }

  private async saveWork(): Promise<void> {
    let a = this.fieldA.trim()
    let b = this.fieldB.trim()
    let c = this.fieldC.trim()
    let mins = 1
    if (this.workKind === 'whitelist') {
      a = this.whitelistText()
      b = ''
      c = ''
    }
    if (this.workKind === 'walk') {
      a = this.walkSec > 0 ? `${this.walkSec}秒` : ''
      mins = this.walkSec > 0 ? Math.ceil(this.walkSec / 60) : 1
    }
    if (a.length === 0 && b.length === 0 && c.length === 0) {
      AtelierDetailNav.showToast('请先写一栏再保存')
      return
    }
    const cardId = AtelierDetailNav.workCardId()
    const item = PracticeItem.of(this.itemId, this.workKind, cardId, this.title, a, b, c, mins,
      AtelierTime.todayKey())
    const saved = await AtelierPractice.save(item)
    this.itemId = saved.id
    AtelierDetailNav.bumpRefresh()
    AtelierDetailNav.showToast('课业已保存，可在「我的课业」回看')
  }

  private async deleteWork(): Promise<void> {
    if (this.itemId.length === 0) {
      AtelierDetailNav.close()
      return
    }
    if (!this.confirmDel) {
      this.confirmDel = true
      AtelierDetailNav.showToast('再点一次确认删除')
      setTimeout((): void => { this.confirmDel = false }, 2200)
      return
    }
    await AtelierPractice.remove(this.itemId)
    AtelierDetailNav.bumpRefresh()
    AtelierDetailNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.title,
        onClose: (): void => { AtelierDetailNav.close() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(PracticeKind.hintOf(this.workKind))
              .fontSize(13)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            this.Fields()
            AppButton({ label: '保存课业', onTap: (): void => { void this.saveWork() } })
            if (this.itemId.length > 0) {
              AppButton({
                label: this.confirmDel ? '再点一次确认删除' : '删除这页课业',
                variant: 'danger',
                onTap: (): void => { void this.deleteWork() }
              })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Fields() {
    if (this.workKind === 'whitelist') {
      Row() {
        Text('日历（必要）').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.cal })
          .onChange((v: boolean): void => { this.cal = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
      Row() {
        Text('电话').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.phone })
          .onChange((v: boolean): void => { this.phone = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
      Row() {
        Text('即时通讯').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.im })
          .onChange((v: boolean): void => { this.im = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
      Row() {
        Text('物流进度').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.logistics })
          .onChange((v: boolean): void => { this.logistics = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
      Row() {
        Text('资讯推送').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.news })
          .onChange((v: boolean): void => { this.news = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
      Row() {
        Text('社交红点').fontSize(15).fontColor(Theme.colorOf(this.themeEpoch).textPrimary).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.social })
          .onChange((v: boolean): void => { this.social = v })
      }.width('100%').padding(12).backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard).borderRadius(8)
    } else if (this.workKind === 'walk') {
      Text(`${Math.floor(this.walkSec / 60)} 分 ${this.walkSec % 60} 秒`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
        .width('100%')
      if (!this.walking) {
        AppButton({ label: '开始出门', onTap: (): void => { this.startWalk() } })
      } else {
        AppButton({ label: '到家停下', variant: 'secondary', onTap: (): void => { this.stopWalk() } })
      }
      AppTextField({
        text: this.fieldB,
        placeholder: '今天走的是哪一条固定回路？',
        multiline: true,
        fieldHeight: 72,
        onChange: (v: string): void => { this.fieldB = v }
      })
    } else {
      AppTextField({
        text: this.fieldA,
        placeholder: this.phA(),
        multiline: true,
        fieldHeight: 80,
        onChange: (v: string): void => { this.fieldA = v }
      })
      AppTextField({
        text: this.fieldB,
        placeholder: this.phB(),
        multiline: true,
        fieldHeight: 80,
        onChange: (v: string): void => { this.fieldB = v }
      })
      AppTextField({
        text: this.fieldC,
        placeholder: this.phC(),
        multiline: true,
        fieldHeight: 80,
        onChange: (v: string): void => { this.fieldC = v }
      })
    }
  }

  private phA(): string {
    if (this.workKind === 'review') {
      return '本周真正交付的结果'
    }
    if (this.workKind === 'aftertaste') {
      return '抄下一句打动你的话'
    }
    return '你看见的轮廓 / 线条'
  }

  private phB(): string {
    if (this.workKind === 'review') {
      return '最大卡点在人、流程还是信息'
    }
    if (this.workKind === 'aftertaste') {
      return '当时你在什么场景、哪种别扭'
    }
    return '哪一处留白让你停下来'
  }

  private phC(): string {
    if (this.workKind === 'review') {
      return '下周只改一件，谁负责'
    }
    if (this.workKind === 'aftertaste') {
      return '用自己的话说给邻座听'
    }
    return '此刻的感受，不必画得像'
  }
}
