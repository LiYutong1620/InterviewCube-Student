-- ⚠️ 已并入 sql/student_init.sql 的第 5 节（题库演示数据）（权威可执行版）。本文件保留留档，内容与合并版逐字一致。
--    从零重建 / 旧库补丁请直接跑对应的合并文件，不必逐个跑本目录的脚本。
-- ----------------------------------------------------------------------------
-- 面立方 · 学生端 · 题库演示数据（question_bank）
--
-- 用途：本地开发 / 演示用。库里没有题库题目时，列表、筛选、查看详情、导出都没法验证，
--       跑一遍这个脚本就能得到 26 道覆盖全部字典值域的样例题。
--
-- 定位：**不是**重建干净库的必需步骤，属于「可选执行」的开发数据。
--       三端合并时**不要**把它当成业务数据合并 —— 真实题库由后台端维护。
--
-- 幂等：每行都带 `where not exists` 守卫（按题干判重），可重复执行，不会产生重复行。
--       已存在同题干的记录时跳过该行，不会覆盖你手工改过的内容。
--
-- 覆盖情况（便于逐项验证筛选与导出）：
--   题型：行为面 6 / 技术面 11 / HR面 5 / case面 4          → 共 24 道「正常」+ 2 道「停用」
--   行业：技术 14 / 产品 5 / 运营 3 / 财务 1 / 教师 3
--   难度：初级 9 / 中级 13 / 高级 4
--   企业类型：BAT 9 / 央企 5 / 外企 4 / 其他 8
--   来源：真题 11 / 模拟 9 / AI生成 6
--   ⚠️ 特意留了 2 道 status='1'（停用，均为技术面），用来验证「停用题目对学生隐藏」是否生效：
--      学生登录后列表应只看到 24 道，导出也应是 24 道；admin 登录应能看到全部 26 道。
--      两道题的题干里都写了「【停用示例】」字样，方便在库里一眼认出验证数据；
--      admin 登录后页面上的「状态」列会显示「停用」（该列仅对有 interview:data:all 权限的账号渲染）。
--
-- 执行位置：sql/README.md 重建顺序之后（任意位置均可，只依赖第 2 步建表）
-- ----------------------------------------------------------------------------

-- ============================ 行为面（question_type = 1） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '请做一个自我介绍，重点说明你与这个岗位的匹配点。', '1', '1', 'Java开发工程师', '1', '1',
       '按「我是谁 → 我做过什么 → 我为什么适合这个岗位」三段式组织，控制在 1 分钟内。避免复述简历流水账，把最相关的 1~2 个项目讲透，并落到岗位要求的关键词上。',
       '["三段式结构清晰","突出与岗位相关的经历","有量化结果","控制在1分钟内"]', '自我介绍,开场', '1', 156, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '请做一个自我介绍，重点说明你与这个岗位的匹配点。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '讲一次你和团队成员产生分歧的经历，你是怎么处理的？', '1', '1', 'Java开发工程师', '2', '1',
       '用 STAR 结构回答。重点不在「谁对谁错」，而在你如何把分歧从「立场之争」拉回「目标与事实」：先对齐目标，再摆数据，必要时做小范围验证。结尾补一句事后如何避免同类分歧。',
       '["STAR结构","先对齐目标再讨论方案","用事实和数据说服","有事后复盘"]', '团队协作,沟通', '1', 98, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '讲一次你和团队成员产生分歧的经历，你是怎么处理的？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说一件你主动推动、但最终没有做成的事，你从中得到什么？', '1', '2', '产品经理', '2', '3',
       '诚实讲失败，但重点放在归因和收获。好的回答会区分「可控因素」和「不可控因素」，并说明如果重来一次你会改变哪个决策点。切忌把失败包装成成功。',
       '["坦诚面对失败","区分可控与不可控因素","有明确的复盘结论","不甩锅"]', '抗压,复盘', '2', 61, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说一件你主动推动、但最终没有做成的事，你从中得到什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你最有成就感的一段经历是什么？为什么？', '1', '3', '运营专员', '1', '4',
       '选一件能体现你能力特长、且与岗位相关的事。回答结构：背景 → 你具体做了什么 → 结果 → 为什么这件事对你重要。把「成就感」落到具体的成长上，而不是空泛的「学到了很多」。',
       '["与岗位能力相关","有具体行动和结果","说清为什么重要"]', '自我认知,动机', '1', 74, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你最有成就感的一段经历是什么？为什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '描述一次你在时间紧张的情况下完成多任务的经历。', '1', '1', '后端开发工程师', '2', '2',
       '展示你的优先级判断方法：按「重要且紧急」排序、主动同步风险、必要时求助或砍范围。要点是让面试官看到你不是靠熬夜硬扛，而是靠方法。',
       '["有明确的优先级判断依据","主动沟通风险","合理取舍范围","结果可验证"]', '时间管理,多任务', '2', 52, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '描述一次你在时间紧张的情况下完成多任务的经历。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你遇到过最难相处的合作对象是什么样的？你怎么应对？', '1', '5', '课程讲师', '2', '4',
       '避免情绪化评价他人。好的回答聚焦「行为差异」而非「人品判断」，并说明你如何调整沟通方式去达成共同目标。',
       '["不评价他人人品","聚焦行为与目标差异","主动调整沟通方式"]', '沟通,冲突处理', '2', 33, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你遇到过最难相处的合作对象是什么样的？你怎么应对？');

-- ============================ 技术面（question_type = 2） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '谈谈 JVM 的内存结构，以及各区域可能出现的异常。', '2', '1', 'Java开发工程师', '2', '1',
       '线程私有：程序计数器、虚拟机栈、本地方法栈；线程共享：堆、方法区（元空间）。程序计数器不会 OOM；虚拟机栈会 StackOverflowError（递归过深）；堆和方法区会 OutOfMemoryError。补充 JDK8 之后方法区由元空间实现、使用本地内存。',
       '["线程私有与线程共享分区正确","程序计数器不OOM","栈溢出与堆溢出的区别","JDK8元空间变化"]', 'JVM,内存模型,八股', '1', 233, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '谈谈 JVM 的内存结构，以及各区域可能出现的异常。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select 'MySQL 的索引为什么用 B+ 树而不是 B 树或哈希表？', '2', '1', 'Java开发工程师', '2', '1',
       '哈希索引不支持范围查询和排序，且哈希冲突时退化。B 树非叶子节点也存数据，单节点能容纳的键更少，树更高、IO 次数更多。B+ 树非叶子节点只存键，扇出大、树更矮；叶子节点用链表相连，天然支持范围扫描和排序，所以更适合磁盘存储。',
       '["哈希不支持范围查询","B树非叶子节点存数据导致扇出小","B+树叶子链表支持范围查询","从磁盘IO角度解释"]', 'MySQL,索引,B+树', '1', 198, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = 'MySQL 的索引为什么用 B+ 树而不是 B 树或哈希表？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说说你对 HTTP 与 HTTPS 区别的理解，HTTPS 的握手过程是怎样的？', '2', '1', '后端开发工程师', '2', '3',
       'HTTPS = HTTP + TLS。核心差异是加密、完整性校验与身份认证。握手大致过程：客户端发 ClientHello（支持的加密套件、随机数）→ 服务端回 ServerHello + 证书 → 客户端校验证书并生成预主密钥、用公钥加密后发送 → 双方用三个随机数推导会话密钥 → 之后用对称加密通信。',
       '["HTTPS是HTTP加TLS","能说清证书校验的作用","握手三步有顺序","最终使用对称加密"]', 'HTTP,HTTPS,TLS', '1', 167, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说说你对 HTTP 与 HTTPS 区别的理解，HTTPS 的握手过程是怎样的？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '什么是幂等？接口设计中如何保证幂等？', '2', '1', '后端开发工程师', '2', '2',
       '幂等指同一请求执行多次，对系统状态的影响与执行一次相同。常见方案：唯一索引/去重表兜底、业务唯一单号、Token 机制（先取 token 再提交）、状态机约束（只允许从指定状态流转）、分布式锁。要说明选型依据：写库场景优先唯一索引，跨服务场景用单号或 token。',
       '["给出幂等的准确定义","至少说出三种方案","说明选型依据","提到唯一索引兜底"]', '接口设计,幂等,分布式', '1', 145, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '什么是幂等？接口设计中如何保证幂等？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '解释一下缓存穿透、缓存击穿、缓存雪崩，以及各自的应对方案。', '2', '1', '高级Java工程师', '3', '1',
       '穿透：查不存在的数据，缓存和数据库都没有，请求全打到库上 —— 用空值缓存、布隆过滤器、参数校验。击穿：某个热点 key 过期瞬间大量请求打到库上 —— 用互斥锁重建、热点 key 永不过期。雪崩：大量 key 同时过期或缓存宕机 —— 过期时间加随机值、多级缓存、缓存集群高可用、限流降级。',
       '["三者定义不混淆","穿透用布隆过滤器或空值缓存","击穿用互斥锁重建","雪崩用随机过期时间与高可用"]', '缓存,Redis,高并发', '1', 189, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '解释一下缓存穿透、缓存击穿、缓存雪崩，以及各自的应对方案。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '一个慢 SQL 你会怎么排查和优化？', '2', '1', '后端开发工程师', '2', '4',
       '先定位：慢查询日志、explain 看 type/key/rows/Extra。再看索引：是否走索引、是否索引失效（函数、隐式类型转换、前导模糊、不符合最左前缀）。优化手段：补合适索引、避免 select *、减少回表、拆分大事务、分页深翻页用游标、必要时引入缓存或归档。',
       '["先用慢日志与explain定位","能说出索引失效的常见原因","优化手段具体","提到深分页问题"]', 'MySQL,慢SQL,优化', '2', 121, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '一个慢 SQL 你会怎么排查和优化？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '说说 TCP 三次握手和四次挥手，为什么需要三次握手？', '2', '1', '后端开发工程师', '1', '3',
       '三次握手：SYN → SYN+ACK → ACK。需要三次是因为要让双方都确认「自己的发送和接收能力正常」以及「对方的发送和接收能力正常」，同时防止已失效的历史连接请求突然到达服务端造成资源浪费。四次挥手：FIN → ACK → FIN → ACK，因为 TCP 是全双工，一方关闭后另一方可能还有数据要发，所以 ACK 与 FIN 不能合并。',
       '["握手挥手步骤正确","能解释为什么不是两次","提到历史连接问题","挥手四次与全双工有关"]', 'TCP,网络,八股', '1', 210, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '说说 TCP 三次握手和四次挥手，为什么需要三次握手？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你了解哪些设计模式？在项目里实际用过哪一个？', '2', '1', 'Java开发工程师', '1', '4',
       '列举常见模式（单例、工厂、策略、模板方法、责任链、观察者等），然后挑一个真正用过的展开：业务场景是什么、不用它之前代码长什么样、用了之后解决了什么问题。面试官想听的是落地经验，不是背定义。',
       '["能列举常见模式","选一个真实用过的展开","说清解决了什么问题","避免只背定义"]', '设计模式,项目经验', '2', 88, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你了解哪些设计模式？在项目里实际用过哪一个？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '分布式锁有哪些实现方式？各自有什么优缺点？', '2', '1', '高级Java工程师', '3', '1',
       '基于 Redis（SET NX EX 或 Redisson）：性能好、实现简单，但要注意锁续期、误删、集群下的一致性问题。基于 ZooKeeper：临时顺序节点，天然支持等待队列、可靠性高，但性能不如 Redis。基于数据库唯一索引或 select for update：实现最简单，但并发能力弱、不适合高并发。选型要看一致性要求与并发量。',
       '["至少三种实现方式","Redis方案的坑能说清","说明选型依据","提到锁续期与误删"]', '分布式锁,Redis,ZooKeeper', '3', 76, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '分布式锁有哪些实现方式？各自有什么优缺点？');

-- ============================ HR面（question_type = 3） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你为什么选择我们公司？', '3', '3', '运营专员', '1', '2',
       '回答要体现你做过功课：公司业务方向、产品特点、你关注到的近期动作，再落到「你的能力能在这里发挥什么」。避免只说「平台大、稳定、离家近」这类放之四海皆准的理由。',
       '["体现做过功课","结合公司业务特点","落到自身能力匹配","不空泛"]', '动机,公司了解', '1', 134, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你为什么选择我们公司？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你的职业规划是什么？未来三年希望达到什么状态？', '3', '2', '产品经理', '2', '2',
       '规划要「可落地且与岗位相关」：第一年熟悉业务与流程、独立负责模块；第二到三年能主导一条业务线、带小团队或形成方法论。切忌说「三年后创业」或「三年当总监」这种与当前岗位脱节的目标。',
       '["规划分阶段且具体","与应聘岗位一致","体现成长意愿","不脱离实际"]', '职业规划,稳定性', '2', 102, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你的职业规划是什么？未来三年希望达到什么状态？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你期望的薪资是多少？依据是什么？', '3', '3', '运营专员', '1', '4',
       '先给一个区间而不是单点，并说明依据：目标城市同岗位市场水平、自己的实习与项目经历、以及该岗位的职责范围。态度上保持可谈，把话题引回「更看重成长空间」。不要在初面阶段把数字咬死。',
       '["给区间不给单点","依据是市场水平与自身能力","态度可谈","不把数字咬死"]', '薪资,谈判', '2', 118, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你期望的薪资是多少？依据是什么？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你能接受加班吗？你怎么看待工作与生活的平衡？', '3', '5', '课程讲师', '1', '4',
       '先表明态度：项目关键期愿意投入，这是团队责任。再说方法：靠提升效率而不是无意义地耗时间，同时说明自己会关注长期可持续。避免两个极端 —— 既不硬顶，也不无条件迎合。',
       '["态度积极但不谄媚","强调提升效率","表达长期可持续","不极端"]', '加班,价值观', '3', 95, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你能接受加班吗？你怎么看待工作与生活的平衡？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '除了我们公司，你还在看哪些机会？如果都拿到 offer 你怎么选？', '3', '2', '产品经理', '2', '3',
       '不必回避在看其他机会，但不要细数别家名字。把重点放在你的选择标准上：业务方向、成长空间、团队氛围、与自身规划的匹配度。最后表明这家公司在你标准里的排序理由。',
       '["不回避也不细数别家","给出清晰的选择标准","说明本公司的排序理由","诚实"]', 'offer选择,动机', '3', 67, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '除了我们公司，你还在看哪些机会？如果都拿到 offer 你怎么选？');

-- ============================ case面（question_type = 4） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '如果某个功能上线后日活下降了 10%，你会怎么分析？', '4', '2', '产品经理', '2', '1',
       '先确认数据本身是否可信（口径变化、埋点问题、统计延迟），再分层拆解：是整体下降还是特定端/地区/人群；再定位是「入口流量少了」还是「转化变差了」；最后结合上线时间点判断是否与本次改版相关，必要时做 A/B 验证。',
       '["先验证数据口径","按维度拆解定位范围","区分流量问题与转化问题","用A/B验证因果"]', '数据分析,case,日活', '1', 143, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '如果某个功能上线后日活下降了 10%，你会怎么分析？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '让你从 0 到 1 设计一个面向大学生的求职工具，你会怎么做？', '4', '2', '产品经理', '3', '1',
       '按「目标用户与场景 → 核心痛点 → 方案与功能优先级 → 指标与验证」展开。求职场景的核心痛点是信息不对称、准备过程无反馈、投递效率低。第一版应聚焦一个点（例如模拟面试或简历诊断），用最小成本验证需求，再考虑扩展。',
       '["先定义用户与场景","痛点具体不空泛","有MVP意识","给出衡量指标"]', '产品设计,case,0到1', '3', 81, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '让你从 0 到 1 设计一个面向大学生的求职工具，你会怎么做？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '公司要求把某个业务的成本降低 20%，你会从哪些方面入手？', '4', '4', '财务分析岗', '3', '2',
       '先做成本结构拆解，找出占比最大的项；再区分固定成本与可变成本、可控与不可控；然后按「影响大小 × 落地难度」排优先级，从可控的大项入手（如供应商议价、流程自动化、减少返工）。要给出量化目标和跟踪机制。',
       '["先拆解成本结构","区分固定与可变成本","按影响与难度排优先级","有量化目标"]', '成本控制,case,财务', '2', 58, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '公司要求把某个业务的成本降低 20%，你会从哪些方面入手？');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '你负责的课程完课率只有 30%，如何提升？', '4', '5', '课程讲师', '2', '4',
       '先定位流失环节：看每一节的跳出率，找出流失最集中的位置；再判断原因（内容太难、时长过长、缺乏反馈、缺少提醒）。对应措施：拆分小节降低单次门槛、增加练习与即时反馈、设置进度提醒与激励机制，最后用小范围实验验证效果。',
       '["用数据定位流失环节","分析原因而非直接给方案","措施对应原因","有验证方式"]', '完课率,case,教学', '3', 42, '0', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '你负责的课程完课率只有 30%，如何提升？');

-- ============================ 停用示例（status = 1，用于验证「对学生隐藏」） ============================

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '【停用示例】这道题已停用，学生端列表和导出都不应出现，admin 登录才看得到。', '2', '1', '后端开发工程师', '1', '4',
       '这是一条用于验证「停用题目对学生隐藏」的样例数据。学生登录后：列表应查不到、直接按 id 访问详情应返回「数据不存在或已删除」、导出里也不应有它。',
       '["仅用于验证status过滤","学生端不可见","admin可见"]', '停用示例,验证数据', '2', 0, '1', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '【停用示例】这道题已停用，学生端列表和导出都不应出现，admin 登录才看得到。');

insert into question_bank (question_content, question_type, industry, job_name, difficulty, company_type, reference_answer, key_points, tags, source, use_count, status, create_by, create_time)
select '【停用示例】内部草稿：题目描述待补充，暂不对外。', '2', '1', 'Java开发工程师', '1', '1',
       '这是第二条停用样例，用于确认多条停用记录都会被过滤掉。',
       '["仅用于验证status过滤","学生端不可见"]', '停用示例,验证数据', '3', 0, '1', 'admin', now()
from dual where not exists (select 1 from question_bank where question_content = '【停用示例】内部草稿：题目描述待补充，暂不对外。');

-- ============================ 校验 ============================
-- 预期：total_cnt = 26，normal_cnt = 24，disabled_cnt = 2
-- 学生账号登录后列表应只有 24 条；admin 登录应能看到 26 条。
select
    (select count(*) from question_bank)                        as total_cnt,
    (select count(*) from question_bank where status = '0')     as normal_cnt,
    (select count(*) from question_bank where status = '1')     as disabled_cnt;
